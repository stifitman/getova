require 'dbconnector'

class IndividualsController < ApplicationController
  before_action :set_individual, only: [:show, :edit, :update, :destroy]

  # GET /individuals
  # GET /individuals.json
  def index
    @individuals = Individual.all
  end

  # GET /individuals/1
  # GET /individuals/1.json
  def show
    puts "show #{params}"
    @individuals = Individual.find(params[:id])
    @representation_formats = IndividualFormat.all
  end

  # GET /individuals/new
  def new
    @individual = Individual.new
  end

  # GET /individuals/1/edit
  def edit
  end

  # GET /curriculum_vitae/1/format
  def get_format
    efh = EuropassFormatHandler.new(Fitman::DBConnector.new(), "http://fitman.sti2.at/base/")
    converter = Converter.new(Fitman::DBConnector.new(),efh)

    IndividualFormat.all.each do |cf|
      puts "#{cf.name} added"
      converter.addFormat(ConverterFormatTransformation.new(cf.name,cf.baseToFormat,cf.formatToBase))
    end

    res = converter.get(params[:id].to_i, params[:format])

    render json: res
  end

  def is_valid_json_if_json(content, format_id)
    json_format_id = IndividualFormat.find_by(name: 'json').id
    json_valid = true
    begin
      if format_id == json_format_id
        JSON.parse params[:icontent]
      end
    rescue JSON::ParserError
      json_valid = false
    end

    json_valid
  end

  # POST /individuals
  # POST /individuals.json
  def create
    @individual = Individual.new(individual_params)
    format_id =  IndividualFormat.find_by(name: params[:selectformat][:id]).id

    puts "adding format: #{format_id} individual_id: #{@individual.id}"
    respond_to do |format|
      json_valid = is_valid_json_if_json(params[:icontent],format_id)
      puts "json is valid: #{json_valid}"
      if json_valid and @individual.save
        puts "saved ind"
        @representation = Representation.new(content: params[:icontent], format_id: format_id, individual_id: @individual.id)
        if @representation.save
          puts "saved rep"
          format.html { redirect_to @representation, notice: 'Individual was successfully created.' }
          format.json { render :show, status: :created, location: @representation }
        else
          puts "could not save rep"
          puts @representation.errors
          format.html { render :new, error: @representation.errors }
          format.json { render json: @representation.errors, status: :unprocessable_entity }
        end
      else
        puts "could not save ind"
        flash[:error] = @individual.errors.full_messages
        unless json_valid
          flash[:error].push "JSON is not valid!"
        end
        format.html { render :new, error: @individual.errors }
        format.json { render json: @individual.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /individuals/1
  # PATCH/PUT /individuals/1.json
  def update
    respond_to do |format|
      if @individual.update(individual_params)
        format.html { redirect_to @individual, notice: 'Individual was successfully updated.' }
        format.json { render :show, status: :ok, location: @individual }
      else
        format.html { render :edit }
        format.json { render json: @individual.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /individuals/1
  # DELETE /individuals/1.json
  def destroy
    Representation.all.each do |r|
      if r.individual_id == @individual.id
        r.destroy
      end
    end
    @individual.destroy
    respond_to do |format|
      format.html { redirect_to individuals_url, notice: 'Individual was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_individual
    @individual = Individual.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def individual_params
    params.require(:individual).permit(:name)
  end
end
