class RegistrationsController < ApplicationController
  skip_before_action :require_login

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params.except(:photo))
    if @user.save
      attach_photo
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Welcome, #{@user.nickname}! Your account has been created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:first_name, :last_name, :email, :nickname,
                                 :password, :password_confirmation, :avatar_url, :photo)
  end

  def attach_photo
    photo = params.dig(:user, :photo)
    @user.photo.attach(photo) if photo.present?
  end
end
