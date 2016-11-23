class UsersController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user, only: %i(edit update)
  before_action :admin_or_elder_user, only: %i(new create destroy)

  def index
    @users = User.order('furigana COLLATE "C"') # TODO: Remove 'COLLATE "C"'
    @years = User.joined_years
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(create_user_params)
    if @user.save
      flash[:success] = "#{@user.full_name} さんを追加しました"
      redirect_to action: :new
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(update_user_params)
      flash[:success] = 'プロフィールを更新しました'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'メンバーを削除しました'
    redirect_to users_url
  end

  private

  def create_user_params
    params.require(:user).permit(:first_name, :last_name, :furigana, :joined)
  end

  def update_user_params
    params.require(:user).permit(:first_name, :last_name, :furigana, :nickname, :email)
  end

  # Before filters

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
end
