class UsersController < ApplicationController
  before_filter :login_required,                    :except => [:index, :show, :new, :create, :activate, :forgot_password, :reset_password]
  before_filter :load_user,                         :except => [:index, :new, :create, :activate, :forgot_password, :reset_password]
  before_filter :should_be_current_user_or_admin,   :except => [:index, :show, :new, :create, :activate, :forgot_password, :reset_password]

  # GET /users
  # GET /users.xml
  def index
    if !params[:search].blank?
      if params[:search] == 'speakers'
        @users = User.ordered.speaker          if admin?
        @users = User.ordered.public_speaker   if !admin?
      elsif params[:search] == 'event_attendees' && !params[:event_id].blank?
        @users = User.ordered.has_paid( params[:event_id] )                 if admin?
        @users = User.ordered.public_profile.has_paid( params[:event_id] )  if !admin?
      end
    elsif !params[:city].blank?
      @city = params[:city].gsub(/[^A-Za-z\ ]+/,'')
      @users = User.find(:all, :conditions => "location_name LIKE '%#{@city}%'")
    elsif !params[:company_name].blank?
      @company_name = params[:company_name].gsub(/[^A-Za-z\ ]+/,'')
      @users = User.find(:all, :conditions => "company_name LIKE '%#{@company_name}%'")
    else
      @users = if admin?
        User.ordered
      else
        User.ordered.activated.public_profile
      end
    end

    params[:page] ||= 1
    @users = @users.paginate( :page => params[:page], :per_page => 25 )

    respond_to do |format|
      format.html
      format.xml { render :xml => @users }
      format.csv { render :csv => @users, :layout => false }
      format.pdf do 
        send_data( 
          PDFGenerator.users_list(@users, current_user), 
          :type => 'application/pdf',
          :filename => "people.pdf", # TODO: use the helper.user_index_title method
          :disposition => 'inline'
        )
      end
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    if( !@user.public_profile && current_user != @user && !admin? )
      @user = nil
      record_not_found
    else
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @user }
      end
    end
  end

  def new
    if using_open_id?
      authenticate_with_open_id(nil, :optional => [:nickname, :email, :fullname]) do |result, identity_url, registration|
        if result.successful?
          if User.exists?(:identity_url => identity_url)
            flash[:error] = t('users.login.open_id_already_exists')
            redirect_to login_path(:openid => true)
          else  
            @user = User.new(:identity_url   => identity_url, 
                             :login          => registration['nickname'], 
                             :email          => registration['email'], 
                             :name           => registration['fullname'], 
                             :public_profile => true)
            flash.now[:notice] = t('users.login.open_id_success')
          end              
        else
          flash.now[:error] = t('users.login.open_id_error', :identity_url => identity_url)
        end
      end
    end
    @user ||= User.new(:public_profile => true)
  end
 
  def create
    logout_keeping_session!
    
    @user = User.new(params[:user])
    
    success = @user && @user.save
    if success && @user.errors.empty?
      redirect_to root_path
      flash[:notice] = t('users.login.signup_success')
    else
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = t('users.login.activation_success')
      self.current_user = user
      redirect_back_or_default('/')
    when params[:activation_code].blank?
      flash[:error] = t('users.login.activation_not_code')
      redirect_back_or_default('/')
    else 
      flash[:error]  = t('users.login.activation_code_not_valid')
      redirect_back_or_default('/')
    end
  end
  
  # GET /users/1/edit
  def edit
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    logger.info("XXX:1: #{params[:user][:password]}")
    if params[:user][:change_password] == "0"
      params[:user][:password] = nil
      params[:user][:password_confirmation] = nil
    end

    logger.info("XXX:2: #{params[:user][:password]}")
    
    if admin? && params[:user][:role]
      @user.role = params[:user][:role]
    end
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = t('users.update.success')
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        flash[:error] = t('users.update.error')
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def forgot_password
    return unless request.post?
    if @user = User.activated.find_by_email(params[:email])
      @user.forgot_password
      redirect_to(login_path)
      flash[:notice] = t('users.reset_password.info')
    else
      flash[:error] = t('users.reset_password.email_not_found', :email => params[:email])
    end
  end

  def reset_password
    @user = User.activated.find_by_password_reset_code(params[:id])  unless params[:id].nil?
    
    if @user.nil? 
      record_not_found
    else
      return unless request.post? && !params[:password].blank?
      @user.password                = params[:password]
      @user.password_confirmation   = params[:password_confirmation]
      @user.password_reset_code     = nil
      if @user.save
        flash[:notice] = t('users.reset_password.success')
        redirect_to login_path
      end
    end
  end
  
  private
    def load_user
      @user = User.find(params[:id])
    end
    
    def should_be_current_user_or_admin
      if( !admin? and current_user != @user )
        record_not_found
      end
    end
end
