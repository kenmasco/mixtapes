class TracksController < ApplicationController

  
  # def new
  #   @mixtape = Mixtape.find params[:mixtape_id]
  #   @track = Track.new(mixtape: @mixtape)
  # end

  def create
    @mixtape = Mixtape.find params[:mixtape_id]
    @track = Track.new(params[:track].permit(:artist, :song))
    @track.mixtapes << @mixtape

    @track.save
    render json: @track.as_json.merge(mixtape_id: @mixtape.id)
  end

  def destroy
    @mixtape = Mixtape.find params[:mixtape_id]
    @track = Track.find params[:id]
    @mixtape.tracks.delete(@track)
    render json: { status: 'success' }
  end

  # def index
  #   @mixtape = Mixtape.find params[:mixtape_id]
  #   @tracks = Track.all

  #   respond_to do |format|
  #     format.html
  #     format.json { render json: @tracks }
  #   end
  # end

  def update
    @mixtape = Mixtape.find params[:id]
    @track = Track.new(params[:track].permit(:artist, :song))
    @track.mixtapes << @mixtape

    @track.save
    render json: @track
  end

end
