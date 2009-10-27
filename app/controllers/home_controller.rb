class HomeController < ApplicationController
  def index
    redirect_to new_session_path and return unless current_user
    redirect_to new_cart_path and return if current_user.carts.all?{|c|c.status == Cart::STATUS[:ON_SESSION]}
    redirect_to papers_path
  end
end
