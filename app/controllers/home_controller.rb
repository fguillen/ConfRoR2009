class HomeController < ApplicationController
  def index
    redirect_to new_cart_path
  end
end
