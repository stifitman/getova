class TanetsController < ApplicationController
  before_action :set_tanet, only: [:show, :edit, :update, :destroy]

  # GET /tanets
  # GET /tanets.json
  def index
    @tanets = Tanet.all
  end

  # GET /tanets/1
  # GET /tanets/1.json
  def show
  end

  # GET /tanets/new
  def new
    @tanet = Tanet.new
  end

  # GET /tanets/1/edit
  def edit
  end

  # POST /tanets
  # POST /tanets.json
  def create
    @tanet = Tanet.new(tanet_params)

    respond_to do |format|
      if @tanet.save
        format.html { redirect_to @tanet, notice: 'Tanet was successfully created.' }
        format.json { render :show, status: :created, location: @tanet }
      else
        format.html { render :new }
        format.json { render json: @tanet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tanets/1
  # PATCH/PUT /tanets/1.json
  def update
    respond_to do |format|
      if @tanet.update(tanet_params)
        format.html { redirect_to @tanet, notice: 'Tanet was successfully updated.' }
        format.json { render :show, status: :ok, location: @tanet }
      else
        format.html { render :edit }
        format.json { render json: @tanet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tanets/1
  # DELETE /tanets/1.json
  def destroy
    @tanet.destroy
    respond_to do |format|
      format.html { redirect_to tanets_url, notice: 'Tanet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tanet
      @tanet = Tanet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tanet_params
      params.require(:tanet).permit(:data)
    end
end
