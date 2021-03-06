# frozen_string_literal: true

class MembersController < ApplicationController
  def index(year = Member.maximum(:joined_year))
    @year = year.to_i
    @members = Member.includes(:avatar, :user).where(joined_year: @year).order(plays_count: :desc)
    raise ActionController::RoutingError, "No members on #{@year}" if @members.empty?
  end

  def show(id)
    @member = Member.find(id)
    @collaborators = Member.includes(:avatar, :user).collaborated_with(@member).with_played_count.to_a
    @songs = @member.published_songs.includes(:live, plays: :member).newest_live_order
  end

  def create(user_registration_form_token, member, user)
    @user_registration_form = UserRegistrationForm.find_by!(token: user_registration_form_token)
    return redirect_to root_path, alert: 'ユーザー登録フォームの有効期限が切れています' if @user_registration_form.expired?

    @member = Member.new(member.permit(:joined_year, :name))
    @member.build_user(user.permit(:email))

    if @member.save(context: :user_registration_form)
      @member.user.invite!
      @user_registration_form.increment!(:used_count) # rubocop:disable Rails/SkipsModelValidations
      InvitationActivityNotifyJob.perform_later(
        user: @user_registration_form.admin.user,
        text: "#{@member.joined_year_and_name} を ID: #{@user_registration_form.id} のユーザー登録フォームで招待しました",
      )
      redirect_to member_path(@member), notice: 'メールを送信しました。メールに記載されているURLにアクセスし、パスワードを設定してください'
    else
      render 'user_registration_forms/show', status: :unprocessable_entity
    end
  end
end
