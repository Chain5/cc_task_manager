require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:alice)
    @task  = tasks(:todo_task)
  end

  # ── Authentication guard ─────────────────────────────────────────────────

  test "GET /tasks redirects unauthenticated users to login" do
    get tasks_path
    assert_redirected_to login_path
  end

  # ── Index ─────────────────────────────────────────────────────────────────

  test "GET /tasks is successful when logged in" do
    sign_in_as @alice
    get tasks_path
    assert_response :success
  end

  # ── Show ──────────────────────────────────────────────────────────────────

  test "GET /tasks/:id shows a task" do
    sign_in_as @alice
    get task_path(@task)
    assert_response :success
  end

  # ── New / Create ──────────────────────────────────────────────────────────

  test "GET /tasks/new renders the new task form" do
    sign_in_as @alice
    get new_task_path
    assert_response :success
  end

  test "POST /tasks with valid params creates a task and redirects" do
    sign_in_as @alice
    assert_difference "Task.count", 1 do
      post tasks_path, params: { task: { title: "Brand new task", priority: "medium" } }
    end
    assert_redirected_to task_path(Task.last)
  end

  test "POST /tasks sets the creator to the current user" do
    sign_in_as @alice
    post tasks_path, params: { task: { title: "My task", priority: "low" } }
    assert_equal @alice, Task.last.creator
  end

  test "POST /tasks with missing title re-renders the form" do
    sign_in_as @alice
    assert_no_difference "Task.count" do
      post tasks_path, params: { task: { title: "", priority: "medium" } }
    end
    assert_response :unprocessable_entity
  end

  # ── Edit / Update ─────────────────────────────────────────────────────────

  test "GET /tasks/:id/edit renders the edit form" do
    sign_in_as @alice
    get edit_task_path(@task)
    assert_response :success
  end

  test "PATCH /tasks/:id with valid params updates the task" do
    sign_in_as @alice
    patch task_path(@task), params: { task: { title: "Updated title", priority: "high" } }
    assert_redirected_to task_path(@task)
    assert_equal "Updated title", @task.reload.title
  end

  test "PATCH /tasks/:id with blank title re-renders the form" do
    sign_in_as @alice
    patch task_path(@task), params: { task: { title: "", priority: "medium" } }
    assert_response :unprocessable_entity
  end

  # ── Destroy ───────────────────────────────────────────────────────────────

  test "DELETE /tasks/:id destroys the task and redirects to index" do
    sign_in_as @alice
    assert_difference "Task.count", -1 do
      delete task_path(@task)
    end
    assert_redirected_to tasks_path
  end

  # ── advance_status ────────────────────────────────────────────────────────

  test "PATCH advance_status advances a todo task to in_progress" do
    sign_in_as @alice
    patch advance_status_task_path(@task)
    assert_equal "in_progress", @task.reload.status
    assert_redirected_to task_path(@task)
  end

  test "PATCH advance_status on a done task redirects with alert" do
    sign_in_as @alice
    done = tasks(:done_task)
    patch advance_status_task_path(done)
    assert_redirected_to task_path(done)
    assert_not_nil flash[:alert]
  end

  # ── move ──────────────────────────────────────────────────────────────────

  test "PATCH move updates task status to a valid value" do
    sign_in_as @alice
    patch move_task_path(@task), params: { status: "done" }
    assert_response :ok
    assert_equal "done", @task.reload.status
  end

  test "PATCH move with invalid status returns unprocessable_entity" do
    sign_in_as @alice
    patch move_task_path(@task), params: { status: "invalid" }
    assert_response :unprocessable_entity
  end
end
