class LivesController < ApplicationController
  before_action :require_current_user, only: :album

  def index
    @lives = Live.published.newest_order
  end

  def show(id)
    @live = Live.published.find(id)
    @songs = @live.songs.with_attached_audio.includes(plays: :member).played_order
  end

  def album(id)
    @live = Live.find(id)

    if @live.album_url.present?
      redirect_to @live.album_url
    else
      raise ActionController::RoutingError, "Live id #{id} does not have album_url"
    end
  end
end
