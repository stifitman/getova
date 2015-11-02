class IndividualFormatsController < ApplicationController
  before_action :set_individual_format, only: [:show, :edit, :update, :destroy]

  # GET /individual_formats
  # GET /individual_formats.json
  def index
    @individual_formats = IndividualFormat.all
  end

  # GET /individual_formats/1
  # GET /individual_formats/1.json
  def show
  end

  # GET /individual_formats/new
  def new
    @individual_format = IndividualFormat.new
  end

  # GET /individual_formats/1/edit
  def edit
  end

  # POST /individual_formats
  # POST /individual_formats.json
  def create
    @individual_format = IndividualFormat.new(individual_format_params)

    respond_to do |format|
      if @individual_format.save
        format.html { redirect_to @individual_format, notice: 'Individual format was successfully created.' }
        format.json { render :show, status: :created, location: @individual_format }
      else
        format.html { render :new }
        format.json { render json: @individual_format.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /individual_formats/1
  # PATCH/PUT /individual_formats/1.json
  def update
    respond_to do |format|
      if @individual_format.update(individual_format_params)
        format.html { redirect_to @individual_format, notice: 'Individual format was successfully updated.' }
        format.json { render :show, status: :ok, location: @individual_format }
      else
        format.html { render :edit }
        format.json { render json: @individual_format.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /individual_formats/1
  # DELETE /individual_formats/1.json
  def destroy
    @individual_format.destroy
    respond_to do |format|
      format.html { redirect_to individual_formats_url, notice: 'Individual format was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_individual_format
      @individual_format = IndividualFormat.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def individual_format_params
      params.require(:individual_format).permit(:name, :baseToFormat, :formatToBase)
    end
end
