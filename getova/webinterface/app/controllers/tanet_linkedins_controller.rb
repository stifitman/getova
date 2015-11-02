class TanetLinkedinsController < ApplicationController
  before_action :set_tanet_linkedin, only: [:show, :edit, :update, :destroy]

  # GET /tanet_linkedins
  # GET /tanet_linkedins.json
  def index
    @tanet_linkedins = TanetLinkedin.all
  end

  # GET /tanet_linkedins/1
  # GET /tanet_linkedins/1.json
  def show
  end

  # GET /tanet_linkedins/new
  def new
    @tanet_linkedin = TanetLinkedin.new
  end

  # GET /tanet_linkedins/1/edit
  def edit
  end

  # GET /scrape_linkedin
  def scrape_person
    url = params[:url]

    profile = Linkedin::Profile.get_profile(url)
    @tanet_linkedin = TanetLinkedin.new
    @tanet_linkedin.name = profile.name
    @tanet_linkedin.data = profile.to_json

    respond_to do |format|
      if @tanet_linkedin.save
        format.html { redirect_to @tanet_linkedin, notice: "#{@tanet_linkedin.name} Linkedin was successfully scraped." }
        format.json { render json: @tanet_linkedin, status: :created}
      else
        format.html { render :new }
        format.json { render json: @tanet_linkedin.errors, status: :unprocessable_entity }
      end
    end

  end

  # POST /tanet_linkedins
  # POST /tanet_linkedins.json
  def create
    @tanet_linkedin = TanetLinkedin.new(tanet_linkedin_params)

    respond_to do |format|
      if @tanet_linkedin.save
        format.html { redirect_to @tanet_linkedin, notice: 'Tanet linkedin was successfully created.' }
        format.json { render :show, status: :created, location: @tanet_linkedin }
      else
        format.html { render :new }
        format.json { render json: @tanet_linkedin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tanet_linkedins/1
  # PATCH/PUT /tanet_linkedins/1.json
  def update
    respond_to do |format|
      if @tanet_linkedin.update(tanet_linkedin_params)
        format.html { redirect_to @tanet_linkedin, notice: 'Tanet linkedin was successfully updated.' }
        format.json { render :show, status: :ok, location: @tanet_linkedin }
      else
        format.html { render :edit }
        format.json { render json: @tanet_linkedin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tanet_linkedins/1
  # DELETE /tanet_linkedins/1.json
  def destroy
    @tanet_linkedin.destroy
    respond_to do |format|
      format.html { redirect_to tanet_linkedins_url, notice: 'Tanet linkedin was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tanet_linkedin
      @tanet_linkedin = TanetLinkedin.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tanet_linkedin_params
      params.require(:tanet_linkedin).permit(:name, :data)
    end
end
