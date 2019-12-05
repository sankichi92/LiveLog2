require 'app_auth0_client'

class UsersController < ApplicationController
  before_action :require_current_user, only: %i[new create]
  before_action :require_not_logged_in_member, only: %i[new create]

  permits :email

  def new
    @user = @member.build_user
  end

  def create(email)
    @user = @member.user

    if @user.nil?
      User.transaction do
        @user = @member.create_user!(email: email)
        @user.create_auth0_user!(email)
      end
    elsif @user.auth0_user.email != email.downcase
      @user.update_auth0_user!(email: email, verify_email: false)
    end

    # Send password reset email.
    AppAuth0Client.instance.change_password(email, nil)

    redirect_to @member, notice: '招待しました'
  rescue Auth0::BadRequest
    @user.errors.add(:email, :invalid)
    render :new, status: :unprocessable_entity
  end

  private

  # region Filters

  def require_not_logged_in_member(member_id)
    @member = Member.find(member_id)
    if @member.user && (@member.user.activated || @member.user.auth0_user.email_verified? || @member.user.auth0_user.has_logged_in?)
      @member.user.activate! unless @member.user.activated?
      redirect_to @member, alert: 'すでにユーザー登録が完了しています'
    end
  end

  # endregion
end
