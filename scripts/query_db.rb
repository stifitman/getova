require 'elasticsearch'
require 'json'

@es_client = Elasticsearch::Client.new host: 'http://192.168.59.103:9200/', log: true



puts @es_client.cluster.health

#def search_companies
#resp = @es_client.search index: 'companies', type: "rdf",  body: {
#  "query" => {
#  "multi_match" => {
#    "regex" => "Asm*",
#    "type" => "most_fields",
#    "fields" => ["c:name"],
#    "slop" => "10"
#  }
#}
#}



def search_companies
  resp = @es_client.search index: 'companies', type: "rdf",  body: {
    "query" => {
    "fuzzy_like_this" => {
    "fields" => ["c:name", "c:produces","c:sells", "c:distribution_for","c:hasLocality","c:locatedInRegion", "c:hasSpeciality",
      "c:country", "c:distributed_by", "c:distribution_for","c:distribution_type","c:postalcode","hasWebsite"],
    "like_text" => "Licht",
    "max_query_terms" => "12"
  }
  }}


  puts JSON.pretty_generate resp
end

#def show
#  res = @es_client.search index: 'tags', id: 'led_tags'
#  res = res['hits']['hits'].first['_source']
#  puts "###################################################################################################"#
#  puts JSON.pretty_generate res
#  puts "###################################################################################################"#
#end
#
#
#
#@es_client = Elasticsearch::Client.new host: 'http://192.168.59.103:9200/', log: true
#def add_tag(type, text)
#
#  puts  @es_client.update index: 'tags',type: 'tag', id: 'led_tags', body:
#    '{
#      "script" : "ctx._source.'+type+' += tag",
#      "lang" : "groovy",
#          "params" : {
#            "tag" : "'+text+'"
#     }
#   }'
#end
#
#
#show
#add_tag "provcat", "ASDFASDF123"
#show



search_companies
