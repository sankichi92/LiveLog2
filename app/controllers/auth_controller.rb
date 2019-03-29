class AuthController < ApplicationController
  before_action :logged_in_user, only: :destroy

  def create
    auth = request.env['omniauth.auth']

    user = Identity.find_with_omniauth(auth)&.user

    if user
      log_in user
      flash[:success] = 'ログインしました'
    elsif (user = current_user)
      Identity.create!(user: user, provider: auth.provider, uid: auth.uid)
      flash[:success] = 'Google アカウントと紐付けました'
    else
      flash[:warning] = '有効なアカウントが見つかりませんでした'
      return redirect_to login_url
    end

    if auth.provider == 'google_oauth2'
      credential = GoogleCredential.find_or_initialize_by(user: user)
      credential.update_with_omniauth!(auth.credentials)
    end

    redirect_back_or user
  end

  def destroy
    if (identity = current_user.identities.google_oauth2.take)
      identity.destroy!
      flash[:success] = 'Google アカウントとの紐付けを解除しました'
    end
    redirect_to current_user
  end

  def failure(message)
    Raven.capture_message(message)
    redirect_to current_user || login_url
  end
end