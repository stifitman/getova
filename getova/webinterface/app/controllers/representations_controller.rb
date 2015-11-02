class RepresentationsController < ApplicationController
  before_action :set_representation, only: [:show, :edit, :update, :destroy]

  # GET /representations
  # GET /representations.json
  def index
    @representations = Representation.all
  end

  # GET /representations/1
  # GET /representations/1.json
  def show
  end

  # GET /representations/new
  def new
    @representation = Representation.new
  end

  # GET /representations/1/edit
  def edit
  end

  # POST /representations
  # POST /representations.json
  def create
    @representation = Representation.new(representation_params)



    respond_to do |format|
      if @representation.save
        format.html { redirect_to @representation, notice: 'Representation was successfully created.' }
        format.json { render :show, status: :created, location: @representation }
      else
        format.html { render :new }
        format.json { render json: @representation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /representations/1
  # PATCH/PUT /representations/1.json
  def update
    respond_to do |format|
      if @representation.update(representation_params)
        format.html { redirect_to @representation, notice: 'Representation was successfully updated.' }
        format.json { render :show, status: :ok, location: @representation }
      else
        format.html { render :edit }
        format.json { render json: @representation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /representations/1
  # DELETE /representations/1.json
  def destroy
    @representation.destroy
    respond_to do |format|
      format.html { redirect_to representations_url, notice: 'Representation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_representation
      @representation = Representation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def representation_params
      params.require(:representation).permit(:individual_id, :content, :format_id)
    end
end
