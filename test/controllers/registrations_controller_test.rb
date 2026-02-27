require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "GET /signup renders the registration page" do
    get signup_path
    assert_response :success
  end

  test "POST /signup with valid data creates user and logs in" do
    assert_difference "User.count", 1 do
      post signup_path, params: {
        user: {
          email: "newuser@example.com",
          nickname: "Newbie",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_redirected_to root_path
  end

  test "POST /signup with mismatched password confirmation is rejected" do
    assert_no_difference "User.count" do
      post signup_path, params: {
        user: {
          email: "newuser@example.com",
          nickname: "Newbie",
          password: "password123",
          password_confirmation: "different"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "POST /signup with duplicate email is rejected" do
    assert_no_difference "User.count" do
      post signup_path, params: {
        user: {
          email: "alice@example.com",
          nickname: "Clone",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "POST /signup with short password is rejected" do
    assert_no_difference "User.count" do
      post signup_path, params: {
        user: {
          email: "newuser@example.com",
          nickname: "Newbie",
          password: "abc",
          password_confirmation: "abc"
        }
      }
    end
    assert_response :unprocessable_entity
  end
end
