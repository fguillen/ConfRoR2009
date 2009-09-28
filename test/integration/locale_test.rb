require File.dirname(__FILE__) + '/../test_helper'

class LocaleTest < ActionController::IntegrationTest
  def setup
    I18n.stubs(:available_locales).returns([:px, :hk, :en, :es])
  end
  
  def test_on_any_request_if_locale_param_found_set_the_locale
    assert_not_equal( 'px', cookies['locale'] )
    get '/login?locale=px'
    assert_response :success
    assert_equal( 'px', cookies['locale'] )
  end
  
  def test_on_any_request_if_locale_param_found_but_not_accepted_not_set_the_locale
    get '/login?locale=wadus'
    assert_response :success
    assert_not_equal( 'wadus', cookies['locale'] )
  end
  
  def test_on_any_request_if_locale_on_cookie_set_the_locale
    I18n.expects('locale=').with('px').once
    cookies[:locale] = 'px'
    get '/login'
    assert_response :success
  end
  
  def test_on_any_request_if_locale_on_request_header_set_the_locale
    I18n.expects('locale=').with('px').once
    get '/login', nil, { :HTTP_ACCEPT_LANGUAGE => 'px' }
    assert_response :success
  end
end