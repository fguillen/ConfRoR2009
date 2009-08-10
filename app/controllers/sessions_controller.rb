# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # render new.rhtml
  def new
  end

  def create
    logout_keeping_session!
    if using_open_id?
      open_id_authentication
    else
      password_authentication
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "Tu sesión ha sido cerrada"
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "No se pudo iniciar sesión cómo '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
  
  def open_id_authentication
    authenticate_with_open_id do |result, identity_url|
      if result.successful? and user = User.find_by_identity_url(identity_url)
        succesful_login(user)
      else
        flash[:error] = "Lo siento, no se pudo iniciar sesión como #{identity_url}"
        redirect_to :action => "new", :openid => true
      end
    end
  end
  
  def password_authentication
    user = User.authenticate(params[:login], params[:password])
    if user
      succesful_login(user)
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end
  
  def succesful_login(user)
    # Protects against session fixation attacks, causes request forgery
    # protection if user resubmits an earlier form using back
    # button. Uncomment if you understand the tradeoffs.
    # reset_session
    self.current_user = user
    new_cookie_flag = (params[:remember_me] == "1")
    handle_remember_cookie! new_cookie_flag
    redirect_back_or_default('/')
    flash[:notice] = "Sesión iniciada correctamente"
  end
  
end
