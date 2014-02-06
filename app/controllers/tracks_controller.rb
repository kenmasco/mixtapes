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
    render json: @track
  end

  def destroy
    @mixtape = Mixtape.find params[:mixtape_id]
    @track = Track.find params[:id]
    @track.destroy
    redirect_to edit_mixtape_path @mixtape
  end

end