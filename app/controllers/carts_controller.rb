class CartsController < ApplicationController
  
  before_filter :login_required, :except => [:notify]
  before_filter :admin_required, :only => [:index, :update]
  
  protect_from_forgery :except => [:notify]

  def index
    @conditions = {}
    
    if !params[:status].blank?
      @conditions = { :status => params[:status] }
    end
    
    @carts = Cart.paginate :page => params[:page], :per_page => 10, 
                           :conditions => @conditions, :order => 'updated_at desc'
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @carts }
    end
  end  
  
  # this is called for the user or admin
  # if not param[:id] sended return the current_cart
  # if params[:id] sended return the Cart but only if admin?
  def new
    @cart = current_cart
    record_not_found and return  if @cart.nil?
    
    @cart.invoice_info = current_user.invoice_info
    
    flash[:notice] = "You have everything paid."  if current_user.everything_paid?
  end
  
  # this is called for the user
  # update the current_cart
  # only add the Event pass through params[:event_ids]
  def confirm
    current_cart.carts_events.destroy_all
    
    # update the default invoce_info of the user
    current_user.update_attribute( :invoice_info, params[:invoice_info] )
    
    if( params[:event_ids].nil? )
      flash[:error] = 'You should select at least one event'
      redirect_to :action => 'new'
      return
    end

    current_cart.attributes = params[:cart]  
    current_cart.events = Event.find( params[:event_ids] )
    # current_cart.invoice_info = params[:invoice_info]
    
    current_cart.save!
        
    events_out_of_capacity = current_cart.events_out_of_capacity
    if !events_out_of_capacity.empty?
      flash[:error] = ''
      events_out_of_capacity.each do |event|
        flash[:error] << (flash[:error].blank? ? 'Sorry, ' : ', ')
        flash[:error] << "the event '#{event.name}' is out of capacity"
      end
      flash[:error] << '.'
      redirect_to :action => 'new'
      return
    end
    
    @cart = current_cart
  end
  
  # this is the IPN paypal action call
  def notify
    logger.info( "XXX: on notify" )
    logger.info( "params: #{params.inspect}" )
  
    @cart = Cart.find( params[:invoice] )
    record_not_found and return  if @cart.nil?
    
    @cart.paypal_notificate( params )
  
    render :nothing => true
  end

  
  # this is the return_url from Paypal
  def complete
    logger.info( "params: #{params.inspect}" )
    
    @cart = current_user.carts.find( params[:invoice] || params[:id] )
    record_not_found and return  if @cart.nil?
    
    # if cart still ON_SESSION for paypal that is because there was no
    # a paypal notification or this is a transfer    
    if @cart.status == Cart::STATUS[:ON_SESSION]
      # @cart.update_attribute( :status, Cart::STATUS[:NOT_NOTIFIED] )
      if @cart.payment_type == 'transfer'
        @cart.update_attribute(:status, Cart::STATUS[:WAIT_TRANSFER])
      else
        @cart.update_attribute( :status, Cart::STATUS[:NOT_NOTIFIED] )
      end
    end
    
    # @cart.update_attribute( :paypal_complete_params, params )
    @cart.update_attribute( :paypal_complete_params, params ) if @cart.payment_type == 'paypal'
    
    if @cart.status == Cart::STATUS[:WAIT_TRANSFER]
      flash.now[:notice] = "Done! Please transfer the funds as soon as possible!"
    elsif @cart.status == Cart::STATUS[:COMPLETED]
       flash.now[:notice] = 'Payment was successful!'
    else
      # still here? something has gone wrong
       flash.now[:error] = 'Something went wrong during the payment process, please contact us!'
     end
  end
  
  def show
    @cart = Cart.find( params[:id] )                if admin?
    @cart = current_user.carts.find( params[:id] )  if !admin?
  end
  
  def update
    @cart = Cart.find(params[:id])
    # Only status is allowed to be updated
    unless params[:status].blank?
      @cart.status = params[:status]
      @cart.save!
      old_locale = I18n.locale
      I18n.locale = 'es'
      if @cart.status == Cart::STATUS[:COMPLETED]
        @cart.send_email_notifications
      end
      I18n.locale = old_locale
    else
      raise t('carts.update.errors.no_status')
    end
    flash.now[:notice] = t('carts.update.success')
    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.js do
        render :update do |page|
          page.replace "cart_#{@cart.id}", :inline => "<p><%= flash[:notice] %></p>"
        end
      end
    end
  rescue
    flash.now[:error] = t('carts.update.error', :error_message => $!)
    respond_to do |format|
      format.html { redirect_to :action => 'index' }
    end
  end
  
end
