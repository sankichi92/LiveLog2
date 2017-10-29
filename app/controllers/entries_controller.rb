class EntriesController < ApplicationController
  before_action :logged_in_user
  before_action :set_live
  before_action :draft_live

  def index
    songs = if params[:order] == 'created_at' || params[:order] == 'updated_at'
              @live.songs.order(params[:order] => :desc).includes(playings: :user)
            else
              @live.songs.order(:time, :order, created_at: :desc).includes(playings: :user)
            end
    @songs = songs.select { |song| song.editable?(current_user) }
  end

  def new
    @song = @live.songs.build
    @song.playings.build
  end

  def create
    @song = @live.songs.build(song_params)
    return unless @song.save
    if @song.send_entry(current_user)
      flash[:success] = '曲の申請メールを送信しました'
    else
      flash[:danger] = 'メールの送信に失敗しました'
    end
    redirect_to action: :index
  rescue ActiveRecord::RecordNotUnique
    @song.add_error_for_duplicated_user
  end

  private

  def set_live
    @live = Live.find(params[:live_id])
  end

  def draft_live
    redirect_to root_url unless @live.draft?
  end

  def song_params
    params.require(:song).permit(:name, :artist, :status, :notes, playings_attributes: %i[id user_id inst _destroy])
  end
end
