class HomeController < ApplicationController
  def index
    redirect_to new_cart_path if current_user
    redirect_to new_session_path
  end
end
