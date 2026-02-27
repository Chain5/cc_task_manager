require "test_helper"

class CommentTest < ActiveSupport::TestCase
  def build_comment(overrides = {})
    Comment.new({ body: "A useful note", task: tasks(:todo_task) }.merge(overrides))
  end

  # ── Validity ──────────────────────────────────────────────────────────────

  test "valid comment is valid" do
    assert build_comment.valid?
  end

  # ── Validations ───────────────────────────────────────────────────────────

  test "body is required" do
    comment = build_comment(body: nil)
    assert_not comment.valid?
    assert comment.errors[:body].any?
  end

  test "blank body is invalid" do
    comment = build_comment(body: "")
    assert_not comment.valid?
    assert comment.errors[:body].any?
  end

  test "task is required" do
    comment = build_comment(task: nil)
    assert_not comment.valid?
    assert comment.errors[:task].any?
  end

  # ── Associations ──────────────────────────────────────────────────────────

  test "user is optional" do
    assert build_comment(user: nil).valid?
  end

  test "comment can belong to a user" do
    comment = build_comment(user: users(:alice))
    assert comment.valid?
    assert_equal users(:alice), comment.user
  end

  test "comment belongs to a task" do
    assert_equal tasks(:todo_task), comments(:first_comment).task
  end
end
