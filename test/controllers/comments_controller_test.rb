require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice   = users(:alice)
    @task    = tasks(:todo_task)
    @comment = comments(:first_comment)
  end

  # ── Create ────────────────────────────────────────────────────────────────

  test "POST /tasks/:id/comments creates a comment and redirects to task" do
    sign_in_as @alice
    assert_difference "Comment.count", 1 do
      post task_comments_path(@task), params: { comment: { body: "New comment" } }
    end
    assert_redirected_to task_path(@task)
  end

  test "POST /tasks/:id/comments sets user to current user" do
    sign_in_as @alice
    post task_comments_path(@task), params: { comment: { body: "Mine" } }
    assert_equal @alice, @task.comments.last.user
  end

  test "POST /tasks/:id/comments with blank body redirects with alert" do
    sign_in_as @alice
    assert_no_difference "Comment.count" do
      post task_comments_path(@task), params: { comment: { body: "" } }
    end
    assert_redirected_to task_path(@task)
    assert_not_nil flash[:alert]
  end

  test "POST /tasks/:id/comments redirects unauthenticated users to login" do
    post task_comments_path(@task), params: { comment: { body: "Sneaky" } }
    assert_redirected_to login_path
  end

  # ── Destroy ───────────────────────────────────────────────────────────────

  test "DELETE /tasks/:id/comments/:id destroys a comment and redirects to task" do
    sign_in_as @alice
    assert_difference "Comment.count", -1 do
      delete task_comment_path(@task, @comment)
    end
    assert_redirected_to task_path(@task)
  end
end
