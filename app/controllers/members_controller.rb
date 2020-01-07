class MembersController < ApplicationController
  def index(year = Member.maximum(:joined_year))
    @year = year.to_i
    @members = Member.with_attached_avatar.where(joined_year: @year).order(plays_count: :desc)
    raise ActionController::RoutingError, "No members on #{@year}" if @members.empty?
  end

  def show(id)
    @member = Member.find(id)
    @collaborators = Member.with_attached_avatar.collaborated_with(@member).with_played_count.to_a
    @songs = @member.published_songs.includes(:live, { plays: :member }).newest_live_order
  end
end
