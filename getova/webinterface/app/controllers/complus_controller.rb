class ComplusController < ApplicationController
  before_action :set_complu, only: [:show, :edit, :update, :destroy]

  # GET /complus
  # GET /complus.json
  def index
    @complus = Complu.all
  end

  # GET /complus/1
  # GET /complus/1.json
  def show
  end

  # GET /complus/new
  def new
    @complu = Complu.new
  end

  # GET /complus/1/edit
  def edit
  end

  # GET /fetch_led_company
  def fetch_led_company
    file = params[:html_data]


    puts "html_data: #{file}"

    uploaded_io = file
    File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
      file.write(uploaded_io.read)
    end

    file_location = Rails.root.join('public', 'uploads', uploaded_io.original_filename)

    extractor = LEDExtraction::CompanyExtractor.new

    extractor.start(
      extractor_name: "Complus LED",
      files: [file_location.to_s],
      send_data_to_server: false,
      store_data_locally: false
    )

    @complu = Complu.create
    @complu.data = extractor.return_usdl
    puts @complu.to_json
    @complu.save

    respond_to do |format|
      format.html{
        if @complu.save!
          redirect_to @complu, notice: 'LED-Company was successfully fetched.'
        else
          redirect_to @complu, notice: @complu.errors
        end
      }
      format.xml { render xml: @complu }
    end

  end

  # POST /complus
  # POST /complus.json
  def create
    @complu = Complu.new(complu_params)

    respond_to do |format|
      if @complu.save
        format.html { redirect_to @complu, notice: 'LED-Company was successfully created.' }
        format.json { render :show, status: :created, location: @complu }
      else
        format.html { render :new }
        format.json { render json: @complu.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /complus/1
  # PATCH/PUT /complus/1.json
  def update
    respond_to do |format|
      if @complu.update(complu_params)
        format.html { redirect_to @complu, notice: 'Complu was successfully updated.' }
        format.json { render :show, status: :ok, location: @complu }
      else
        format.html { render :edit }
        format.json { render json: @complu.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /complus/1
  # DELETE /complus/1.json
  def destroy
    @complu.destroy
    respond_to do |format|
      format.html { redirect_to complus_url, notice: 'Complu was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_complu
    @complu = Complu.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def complu_params
    params.require(:complu).permit(:data)
  end
end
