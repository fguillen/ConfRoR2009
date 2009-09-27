require File.dirname(__FILE__) + '/../test_helper'

class LocaleControllerTest < ActionController::TestCase
  def setup
  end
  
  def test_on_set_locale
    assert_not_equal( 'px', @request.session[:locale] )
    get( :set_locale, :locale => 'px' )
    assert_equal( 'px', @request.session[:locale] )
    
    assert_redirected_to '/'
  end
  
  def test_on_set_locale_from_param
    # I should call to another controller to see if the 
    # ApplicationController.set_session_locale set the locale on any controller action
    # Done on PapersControllerTest.test_set_locale_from_param
  end
end
