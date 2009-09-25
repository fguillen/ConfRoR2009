class LocaleController < ApplicationController
  def set_locale
    session[:locale] = params[:locale]
    redirect_to root_path
  end
end