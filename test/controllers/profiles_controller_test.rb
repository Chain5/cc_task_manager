require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup { @alice = users(:alice) }

  # ── Authentication guard ─────────────────────────────────────────────────

  test "GET /profile/edit redirects unauthenticated users to login" do
    get edit_profile_path
    assert_redirected_to login_path
  end

  test "PATCH /profile redirects unauthenticated users to login" do
    patch profile_path, params: { user: { nickname: "Ghost" } }
    assert_redirected_to login_path
  end

  # ── Edit ──────────────────────────────────────────────────────────────────

  test "GET /profile/edit renders the edit form" do
    sign_in_as @alice
    get edit_profile_path
    assert_response :success
  end

  # ── Update — name fields ───────────────────────────────────────────────────

  test "PATCH /profile updates first_name and last_name" do
    sign_in_as @alice
    patch profile_path, params: {
      user: { first_name: "Alice", last_name: "Wonder", nickname: @alice.nickname,
              email: @alice.email }
    }
    assert_redirected_to root_path
    @alice.reload
    assert_equal "Alice",  @alice.first_name
    assert_equal "Wonder", @alice.last_name
  end

  test "PATCH /profile updates nickname" do
    sign_in_as @alice
    patch profile_path, params: {
      user: { nickname: "AliceNew", email: @alice.email }
    }
    assert_redirected_to root_path
    assert_equal "AliceNew", @alice.reload.nickname
  end

  test "PATCH /profile with blank nickname re-renders the form" do
    sign_in_as @alice
    patch profile_path, params: { user: { nickname: "", email: @alice.email } }
    assert_response :unprocessable_entity
  end

  # ── Update — email ────────────────────────────────────────────────────────

  test "PATCH /profile updates email and downcases it" do
    sign_in_as @alice
    patch profile_path, params: {
      user: { nickname: @alice.nickname, email: "NEW@EXAMPLE.COM" }
    }
    assert_redirected_to root_path
    assert_equal "new@example.com", @alice.reload.email
  end

  test "PATCH /profile with invalid email re-renders the form" do
    sign_in_as @alice
    patch profile_path, params: {
      user: { nickname: @alice.nickname, email: "not-an-email" }
    }
    assert_response :unprocessable_entity
  end

  test "PATCH /profile with duplicate email re-renders the form" do
    sign_in_as @alice
    patch profile_path, params: {
      user: { nickname: @alice.nickname, email: users(:bob).email }
    }
    assert_response :unprocessable_entity
  end

  # ── Update — password ─────────────────────────────────────────────────────

  test "PATCH /profile with blank password does not change password" do
    sign_in_as @alice
    original_digest = @alice.password_digest
    patch profile_path, params: {
      user: { nickname: @alice.nickname, email: @alice.email,
              password: "", password_confirmation: "" }
    }
    assert_redirected_to root_path
    assert_equal original_digest, @alice.reload.password_digest
  end

  test "PATCH /profile with a new password updates it" do
    sign_in_as @alice
    patch profile_path, params: {
      user: { nickname: @alice.nickname, email: @alice.email,
              password: "newpassword", password_confirmation: "newpassword" }
    }
    assert_redirected_to root_path
    assert @alice.reload.authenticate("newpassword")
  end

  test "PATCH /profile with too-short password re-renders the form" do
    sign_in_as @alice
    patch profile_path, params: {
      user: { nickname: @alice.nickname, email: @alice.email,
              password: "abc", password_confirmation: "abc" }
    }
    assert_response :unprocessable_entity
  end

  test "PATCH /profile with mismatched password confirmation re-renders the form" do
    sign_in_as @alice
    patch profile_path, params: {
      user: { nickname: @alice.nickname, email: @alice.email,
              password: "newpassword", password_confirmation: "different" }
    }
    assert_response :unprocessable_entity
  end

  # ── Update — avatar URL ───────────────────────────────────────────────────

  test "PATCH /profile updates avatar_url" do
    sign_in_as @alice
    patch profile_path, params: {
      user: { nickname: @alice.nickname, email: @alice.email,
              avatar_url: "https://example.com/pic.png" }
    }
    assert_redirected_to root_path
    assert_equal "https://example.com/pic.png", @alice.reload.avatar_url
  end
end
