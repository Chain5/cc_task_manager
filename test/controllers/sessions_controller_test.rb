require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "GET /login renders the login page" do
    get login_path
    assert_response :success
  end

  test "POST /login with valid credentials logs in and redirects to root" do
    post login_path, params: { email: "alice@example.com", password: "password123" }
    assert_redirected_to root_path
  end

  test "POST /login with wrong password is rejected" do
    post login_path, params: { email: "alice@example.com", password: "wrong" }
    assert_response :unprocessable_entity
  end

  test "POST /login with unknown email is rejected" do
    post login_path, params: { email: "nobody@example.com", password: "password123" }
    assert_response :unprocessable_entity
  end

  test "DELETE /logout clears session and redirects to login" do
    sign_in_as users(:alice)
    delete logout_path
    assert_redirected_to login_path
  end
end
