require File.dirname(__FILE__) + '/../test_helper'

class SessionsControllerTest < ActionController::TestCase
  def test_on_login_with_openid_should_not_loggin_if_user_not_active
    result = OpenIdAuthentication::Result.new(:successful)
    existing_identity = users(:user_existing_with_openid_not_actived).identity_url
    @controller.stubs(:authenticate_with_open_id).yields(result, existing_identity, nil)
  
    get(
      :create,
      :openid_identifier => users(:user_existing_with_openid_not_actived).identity_url
    )
    
    assert_nil( @controller.send(:current_user) )
    assert_match("no se pudo iniciar sesión como #{users(:user_existing_with_openid_not_actived).identity_url}", flash[:error])
    assert_nil( flash[:notice] )
    assert_redirected_to login_path(:openid => true)
  end
  
  def test_on_login_with_openid_should_loggin
    result = OpenIdAuthentication::Result.new(:successful)
    existing_identity = users(:user_existing_with_openid).identity_url
    @controller.stubs(:authenticate_with_open_id).yields(result, existing_identity, nil)
  
    get(
      :create,
      :openid_identifier => users(:user_existing_with_openid).identity_url
    )
    
    assert_equal( users(:user_existing_with_openid), @controller.send(:current_user) )
    assert_match("Sesión iniciada correctamente", flash[:notice])
    assert_nil( flash[:error] )
    assert_redirected_to root_path
  end
end
