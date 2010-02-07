require 'test_helper'
require 'authlogic/test_case'

class UsersControllerTest < ActionController::TestCase
  setup :activate_authlogic 

  test "show user matches the correct id" do 
    get(:show, {'id' => users(:sarah).id})
    assert_response :success
    assert_not_nil assigns(:user)
    assert assigns(:user).id == users(:sarah).id
  end

  test "redirect if user already exists" do 
    UserSession.create(users(:sarah))
    post(:create, :user => {"first_name" => "Sam",
                       "last_name" => "Gibson",
                       "email" => "sam@ifdown.net",
                       "password" => "password",
                       "password_confirmation" => "password"})
    assert_redirected_to user_url(:id => users(:sarah).id)
  end

  test "can create new user" do
    post(:create, :user => {"first_name" => "Sam",
                       "last_name" => "Gibson",
                       "email" => "sam@ifdown.net",
                       "password" => "password",
                       "password_confirmation" => "password"})
    user = User.find_by_email("sam@ifdown.net")
    assert_not_nil user

    # User should have been logged in automatically
    assert_not_nil UserSession.find

    assert_redirected_to user_url(:id => user.id)
  end

  test "won't create user without correct password confirmation" do
    assert_no_difference("User.count") do
      post(:create, :user => {"first_name" => "Sam",
                         "last_name" => "Gibson",
                         "email" => "sam@ifdown.net",
                         "password" => "password",
                         "password_confirmation" => "foo"})
      assert_response :success
    end
  end
end
