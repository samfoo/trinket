require 'test_helper'
require 'authlogic/test_case'

class UserSessionsControllerTest < ActionController::TestCase
  setup :activate_authlogic 

  test "logout" do
    # Creating the user automatically logs it in.
    User.create!(:first_name => "Sherlock",
                 :last_name => "Holmes",
                 :email => "sherlock.holmes@bakerst.co.uk",
                 :password => "password",
                 :password_confirmation => "password")
    assert_not_nil UserSession.find
    get(:destroy)
    assert_nil UserSession.find
    assert_redirected_to "/"
  end

  test "logout not logged in" do
    get(:destroy)
    assert_nil UserSession.find
    assert_redirected_to "/"
  end

  test "login success" do
    User.create!(:first_name => "Sherlock",
                 :last_name => "Holmes",
                 :email => "sherlock.holmes@bakerst.co.uk",
                 :password => "password",
                 :password_confirmation => "password")
    UserSession.find.destroy

    post(:create, :user => {"email" => "sherlock.holmes@bakerst.co.uk",
                            "password" => "password"})
    assert_not_nil UserSession.find
    assert_redirected_to user_url(:id => UserSession.find.record.id)
  end

  test "login failure" do
    post(:create, :user => {"email" => "sherlock.holmes@bakerst.co.uk",
                            "password" => "password"})
    assert_nil UserSession.find
    assert_redirected_to login_url 
  end
end
