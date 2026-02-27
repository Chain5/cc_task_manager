require "test_helper"

class UserTest < ActiveSupport::TestCase
  def build_user(overrides = {})
    User.new({ email: "test@example.com", nickname: "Tester", password: "password123" }.merge(overrides))
  end

  # ── Validity ──────────────────────────────────────────────────────────────

  test "valid user is valid" do
    assert build_user.valid?
  end

  # ── Email validations ──────────────────────────────────────────────────────

  test "email is required" do
    assert_not build_user(email: nil).valid?
  end

  test "email format is validated" do
    user = build_user(email: "not-an-email")
    assert_not user.valid?
    assert_includes user.errors[:email], "is not a valid address"
  end

  test "email must be unique" do
    user = build_user(email: users(:alice).email)
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "email is downcased before save" do
    user = build_user(email: "Mixed@CASE.com")
    user.save!
    assert_equal "mixed@case.com", user.reload.email
  end

  # ── Nickname validations ───────────────────────────────────────────────────

  test "nickname is required" do
    assert_not build_user(nickname: nil).valid?
  end

  test "nickname shorter than 2 characters is invalid" do
    assert_not build_user(nickname: "A").valid?
  end

  test "nickname of exactly 2 characters is valid" do
    assert build_user(nickname: "Al").valid?
  end

  test "nickname longer than 30 characters is invalid" do
    assert_not build_user(nickname: "A" * 31).valid?
  end

  test "nickname of exactly 30 characters is valid" do
    assert build_user(nickname: "A" * 30).valid?
  end

  # ── Password validations ───────────────────────────────────────────────────

  test "password shorter than 6 characters is invalid" do
    assert_not build_user(password: "abc").valid?
  end

  test "password of exactly 6 characters is valid" do
    assert build_user(password: "abcdef").valid?
  end

  # ── Instance methods ───────────────────────────────────────────────────────

  # ── first_name / last_name validations ────────────────────────────────────

  test "first_name longer than 50 characters is invalid" do
    assert_not build_user(first_name: "A" * 51).valid?
  end

  test "first_name of exactly 50 characters is valid" do
    assert build_user(first_name: "A" * 50).valid?
  end

  test "blank first_name is valid" do
    assert build_user(first_name: "").valid?
  end

  test "last_name longer than 50 characters is invalid" do
    assert_not build_user(last_name: "A" * 51).valid?
  end

  # ── initials ──────────────────────────────────────────────────────────────

  test "initials returns single letter for one-word nickname" do
    assert_equal "A", build_user(nickname: "Alice").initials
  end

  test "initials returns two letters for multi-word nickname" do
    assert_equal "JD", build_user(nickname: "John Doe").initials
  end

  test "initials returns at most two letters" do
    assert_equal "JD", build_user(nickname: "John David Smith").initials
  end

  test "initials are uppercased" do
    assert_equal "AB", build_user(nickname: "alpha beta").initials
  end

  test "initials prefer first_name and last_name over nickname when set" do
    user = build_user(nickname: "Anything", first_name: "Jane", last_name: "Doe")
    assert_equal "JD", user.initials
  end

  test "initials use only first_name initial when last_name is blank" do
    user = build_user(nickname: "Anything", first_name: "Jane", last_name: "")
    assert_equal "J", user.initials
  end

  # ── display_name ──────────────────────────────────────────────────────────

  test "display_name returns full name when first and last name are set" do
    user = build_user(first_name: "Jane", last_name: "Doe")
    assert_equal "Jane Doe", user.display_name
  end

  test "display_name returns first name only when last name is blank" do
    user = build_user(first_name: "Jane", last_name: "")
    assert_equal "Jane", user.display_name
  end

  test "display_name falls back to nickname when no first or last name" do
    user = build_user(nickname: "janedoe", first_name: nil, last_name: nil)
    assert_equal "janedoe", user.display_name
  end

  test "avatar_color returns a value from the palette" do
    assert_includes User::AVATAR_PALETTE, users(:alice).avatar_color
  end

  test "avatar_color is deterministic for the same user" do
    user = users(:alice)
    assert_equal user.avatar_color, user.avatar_color
  end

  # ── Associations ───────────────────────────────────────────────────────────

  test "user has many created tasks" do
    assert_respond_to users(:alice), :created_tasks
  end

  test "user has many assigned tasks" do
    assert_respond_to users(:alice), :assigned_tasks
  end

  test "user has many comments" do
    assert_respond_to users(:alice), :comments
  end

  test "destroying user nullifies their created tasks" do
    user  = users(:alice)
    task  = tasks(:high_priority_task)
    assert_equal user.id, task.creator_id

    user.destroy
    assert_nil task.reload.creator_id
  end
end
