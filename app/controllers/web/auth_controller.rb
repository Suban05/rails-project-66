# frozen_string_literal: true

module Web
  class AuthController < ApplicationController
    def callback
      return redirect_to root_path, notice: t('.already_signed_in') if signed_in?

      auth_params = request.env['omniauth.auth']
      user = find_or_initialize_user(auth_params)

      if user.save
        sign_in user
        redirect_to root_path, notice: t('.signed_in')
      else
        redirect_to root_path, alert: user.errors.full_messages.to_sentence
      end
    end

    def logout
      sign_out
      redirect_to root_path, notice: t('.signed_out')
    end

    private

    def find_or_initialize_user(auth_params)
      user = User.find_or_initialize_by(email: auth_params[:info][:email].downcase)
      user.token = auth_params[:credentials][:token]

      return user if user.persisted?

      user.nickname = auth_params[:info][:nickname]
      user.email = auth_params[:info][:email]

      user
    end
  end
end
