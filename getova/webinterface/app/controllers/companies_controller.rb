require 'company_extractor'
require 'rdf'
require 'rdf/ntriples'
require 'sparql'
require 'json'
require 'patron'

class CompaniesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_company, only: [:show, :edit, :update, :destroy]



  @@es_client = Elasticsearch::Client.new host: ENV['elastic_search_ip'], log: true
  @@deletion_just_happend = false
  # GET /companies
  # GET /companies.json
  def index
    @companies = Company.order(:name)

    tags = params[:terms]

    unless tags.nil?
      if tags.class == Array.new
        tags = tags.inject { |m, x|  m + x}
      end
      json_companies = search_elastic tags
      results = Array.new

      json_companies.each do |c|
        puts "searching for #{c}"
        company_found = Company.find_by( :name => c['_id'])
        puts "found #{company_found}"
        results << company_found unless company_found.nil?
      end

      results.each do |c|
        puts "@companies #{c.name}"
      end
      @companies = results
    end

  end

  # GET /companies/1
  # GET /companies/1.json
  def show
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  def search_elastic(term)
    resp = @@es_client.search index: 'companies', type: "rdf",  body: {
      "query" => {
      "fuzzy_like_this" => {
      "fields" => ["name", "produces","sells", "distribution_for","hasLocality","locatedInRegion", "hasSpeciality",
        "country", "distributed_by", "distribution_for","distribution_type","postalCode","hasWebsite", "hasStreetAddress","hasMail" ],
        "like_text" => term,
        "max_query_terms" => "30"
    }
    }}

    results = Array.new
    resp['hits']['hits'].each do |r|
      results << r
    end

    puts "Results of search_elastic #{results}"
        results
  end

  def transform_elastic_result_for_autocomplete(elastic_data)
    results = Array.new
    elastic_data.each do |r|
      results << {
        "label" => r['_source']['c:name'],
        "value" => "name"
      }
    end
    results
  end

  # GET /companies/search
  def search
    term = params[:term]

    wordlist =  transform_elastic_result_for_autocomplete(search_elastic(term))

    annotations =  @@es_client.search index: 'tags', id: 'led_tags'
    annotations = annotations['hits']['hits'].first['_source']

    annotations.each do |k,v|
      v.each do |word|
        wordlist <<  {
          "label" => word,
          "value" => k
        }
      end
    end

    fuzzyword = FuzzyMatch.new(wordlist).find(term)

    terms = term.split

    results = Array.new

    terms.each do |t|
      puts "SEARCH #{t}"
      result  =  wordlist.select {|k|
        found = false
        (k.values.each do |v|
          next if v.nil?
          if v.include? t
            puts "match #{v}"
            found = true
          end
        end
        found)
      }

      results.concat result unless result.nil?
    end
    results << fuzzyword
    results.uniq!

    puts "Found:"
    puts results

    respond_to do |format|
      format.html { render json: results }
      format.json { render json: results }
    end
  end


  # POST /companies
  # POST /companies.json
  def create
    @company = Company.new company_params

    unless @company.nil?
      rdf = getJsonld(@company[:content]).to_json
      usdl = getJsonld(@company[:usdl]).to_json
      puts "#{@company.name}"
      puts "sending to elasticsearch@#{ENV['elastic_search_ip']}"
      puts "#{@es_client}"
      x = @company.name
      plain_json = jsonld2json rdf
      @@es_client.index  index: 'companies', type: 'rdf', id: x ,   body: plain_json
      @@es_client.index  index: 'companies', type: 'usdl', id: @company.name,   body: usdl
      @company.json = rdf


      data = JSON.pretty_generate(plain_json).to_s
      if plain_json["c:extra"] == "tanet"
        Tanet.create :data => data
      elsif plain_json["c:extra"] == "complus"
        Complu.create :data => data
      else
        puts "DATA:::: plain json"
        puts "#{plain_json}###################################################################################################"
      end
    end

    respond_to do |format|
      if @company.save

        puts "asdf: #{@company.inspect}"

        format.html { redirect_to @company, notice: 'Company was successfully created.' }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end


  def run_clustering_neccesary?
    latestRun = ClusterRun.order(:updated_at).last
    companies = Company.all

    if @@deletion_just_happend
      puts "rerun clustering because of deletion!"
      @@deletion_just_happend = false
      return true
    end

    return true if latestRun.nil?

    companies.each do |c|
      if c.updated_at > latestRun.updated_at
        return true
      end
    end

    puts "CLUSTERING NOT NECESSARY"
    false
  end

  def prepare_data_for_clustering
    companies = Company.all
    companies.each do |c|
      data = StringIO.new(c.content)
      begin
        reader = RDF::Reader.for(:ntriples).new(data)
        repo = RDF::Repository.new

        reader.each do |i|
          repo.insert(i)
        end

        store = c.name + ": "
        query = SPARQL.parse("SELECT ?o WHERE {?s ?p ?o }")
        # store = SPARQL.execute("SELECT ?o WHERE {?s ?p ?o }",repo).to_html
        query.execute(repo).each do |result|
          store += " " + result[:o].value
        end
        File.open("data_extractor/rdf/" + c.name.gsub(/[^0-9A-Za-z]/, ''), 'w') { |file| file.write(store) }
      rescue
        puts "There was a problem preparing #{c.name} for clustering"
      end
    end
  end

  def start_clustering
    ClusterRun.create
    system 'rm -rf data_extractor/rdf'
    system 'mkdir data_extractor'
    system 'mkdir data_extractor/rdf'
    system 'rm data_extractor/clusterdump'

    prepare_data_for_clustering
    system 'echo "rails calling run_mahout"'
    system 'pwd'
    system 'sh lib/run_mahout.sh' #necessary to not run with & for docker not to crash
    system 'echo "clustering stopped"'
  end

  #GET /companies/clustering
  def run_clustering
    latestRun = ClusterRun.order(:updated_at)[0]
    companies = Company.all


    if run_clustering_neccesary?
      @clusterresult = nil
      start_clustering
    end

    begin
      results = open("data_extractor/clusterdump", &:read)
      results_json = open("data_extractor/clusterdump.json", &:read)
      # results = results.split("\n").to_json
      # json = JSON.parse(results)
      # results = JSON.pretty_generate json
    rescue
      results = "Clustering is not done yet"
      results_json = "{'note': 'clustering is still running'}"
    end

    @clusterresult = results
    respond_to do |format|
      format.html { render "_clustering.erb" }
      format.json { render json: results_json }
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    respond_to do |format|

      unless @company.nil?
        rdf = getJsonld(@company[:content]).to_json
        usdl = getJsonld(@company[:usdl]).to_json
        #puts "sending to elasticsearch@#{ENV['elastic_search_ip']}"
        @es_client.index  index: 'companies', type: 'rdf', id: @copmany.name,   body: rdf
        @es_client.index  index: 'companies', type: 'usdl', id: @company.name,   body: usdl
        @company.json = rdf
      end
      if @company.update(company_params)

        format.html { redirect_to @company, notice: 'Company was successfully updated.' }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end



  def get_json_for_d3
    begin
      results = open("data_extractor/clusterdump.csv", &:read)
    rescue
      results = "Clustering is not done yet"
    end

    clusters = results.split("\n")
    d3json = Hash.new

    index = 0
    d3json[:name] = "Clusters"
    d3json[:children] = Array.new
    clusters.each do |c|
      index += 1
      cluster = Hash.new
      cluster_elements = c.split(',')
      cluster_elements.delete_at(0)
      cluster[:name] = "Cluster " + index.to_s
      cluster[:children] = Array.new
      cluster_elements.each do |e|
        cluster_element = Hash.new
        cluster_element[:name] = e[1,e.length]
        cluster_element[:size] = 200 + cluster_element[:name].size * 45
        cluster[:children].push cluster_element
      end

      d3json[:children].push cluster
    end

    respond_to do |format|
      format.html {render json: d3json}
      format.json {render json: d3json}
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company.destroy
    @@deletion_just_happend = true
    puts "deletion happend. flag set"
    respond_to do |format|
      format.html { redirect_to companies_url, notice: 'Company was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def company_params
    puts "hello: #{params}"
    params.require(:company).permit(:name, :content , :usdl, :jsonld)
  end

  def getJsonld(rdf)
    input = RDF::Graph.new << RDF::Reader.for(:ntriples).new(rdf)
    context = JSON.parse %({
    "@context": {
        "gr": "http://purl.org/goodrelations/v1#",
        "s": "http://schema.org/address",
        "v": "http://www.w3.org/2006/vcard/ns#",
        "l": "http://www.linked-usdl.org/ns/usdl-core#",
        "foaf": "http://xmlns.com/foaf/0.1/",
        "c": "http://fitman.sti2.at/company/"
   }
   })
   compacted = nil
   JSON::LD::API::fromRdf(input) do |expanded|
     compacted = JSON::LD::API.compact(expanded, context['@context'])
   end

   compacted
  end


  def jsonld2json(jsonld)

    if jsonld.class == String
      puts "jsonld was a string"
      jsonld = JSON.parse(jsonld)
      puts jsonld
    end

    jsonld.delete '@context'
    puts "remove context:"
    puts jsonld

    jsonld = jsonld['@graph'].first unless jsonld['@graph'].nil?
    # jsonld = jsonld['@graph'].second unless jsonld['@graph'].nil?
    puts "first"
    puts jsonld
    return jsonld

    plain = Hash.new
    jsonld.each do |k,v|
      key = k
      match_result = k.match('(:)(\w+)')
      puts "matchresult: #{match_result}"
      key = match_result[2].to_s unless match_result.nil?

      plain[key] = v.strip if v.class == String
    end
    puts "####################################################################################################"
    puts plain
    puts "####################################################################################################"
    return plain
  end

end
