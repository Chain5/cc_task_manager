class ProfilesController < ApplicationController
  def edit
    @user = current_user
  end

  def update
    @user = current_user
    avatar_url = params.dig(:user, :avatar_url).presence

    if @user.update(profile_params.except(:photo))
      if avatar_url
        @user.photo.purge if @user.photo.attached?
      else
        attach_photo
      end
      redirect_to root_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    permitted = params.require(:user).permit(
      :first_name, :last_name, :nickname, :email,
      :password, :password_confirmation,
      :avatar_url, :photo
    )
    # Only update password when the user explicitly fills it in
    if permitted[:password].blank?
      permitted.delete(:password)
      permitted.delete(:password_confirmation)
    end
    permitted
  end

  def attach_photo
    photo = params.dig(:user, :photo)
    @user.photo.attach(photo) if photo.present?
  end
end
