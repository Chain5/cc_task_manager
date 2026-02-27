require "test_helper"

class TaskTest < ActiveSupport::TestCase
  def build_task(overrides = {})
    Task.new({ title: "Test task" }.merge(overrides))
  end

  # ── Validity ──────────────────────────────────────────────────────────────

  test "valid task is valid" do
    assert build_task.valid?
  end

  # ── Validations ───────────────────────────────────────────────────────────

  test "title is required" do
    task = build_task(title: nil)
    assert_not task.valid?
    assert task.errors[:title].any?
  end

  test "status must be a known value" do
    task = build_task(status: "unknown")
    assert_not task.valid?
    assert task.errors[:status].any?
  end

  test "priority must be a known value" do
    task = build_task(priority: "super_ultra")
    assert_not task.valid?
    assert task.errors[:priority].any?
  end

  # ── Defaults ──────────────────────────────────────────────────────────────

  test "default status is todo" do
    task = Task.new(title: "No status set")
    task.valid?
    assert_equal "todo", task.status
  end

  test "default priority is medium" do
    task = Task.new(title: "No priority set")
    task.valid?
    assert_equal "medium", task.priority
  end

  # ── Status transitions ────────────────────────────────────────────────────

  test "can_advance? is true for todo" do
    assert tasks(:todo_task).can_advance?
  end

  test "can_advance? is true for in_progress" do
    assert tasks(:in_progress_task).can_advance?
  end

  test "can_advance? is false for done" do
    assert_not tasks(:done_task).can_advance?
  end

  test "next_status from todo is in_progress" do
    assert_equal "in_progress", tasks(:todo_task).next_status
  end

  test "next_status from in_progress is done" do
    assert_equal "done", tasks(:in_progress_task).next_status
  end

  test "next_status from done is nil" do
    assert_nil tasks(:done_task).next_status
  end

  test "advance_status! moves todo to in_progress" do
    task = tasks(:todo_task)
    task.advance_status!
    assert_equal "in_progress", task.reload.status
  end

  test "advance_status! moves in_progress to done" do
    task = tasks(:in_progress_task)
    task.advance_status!
    assert_equal "done", task.reload.status
  end

  test "advance_status! raises when task is already done" do
    assert_raises(RuntimeError) { tasks(:done_task).advance_status! }
  end

  # ── Label / CSS helpers ───────────────────────────────────────────────────

  test "status_label for todo" do
    assert_equal "To do", tasks(:todo_task).status_label
  end

  test "status_label for in_progress" do
    assert_equal "In progress", tasks(:in_progress_task).status_label
  end

  test "status_label for done" do
    assert_equal "Completed", tasks(:done_task).status_label
  end

  test "status_css replaces underscores with dashes" do
    assert_equal "in-progress", tasks(:in_progress_task).status_css
  end

  test "priority_label returns human-readable string" do
    assert_equal "High",      tasks(:in_progress_task).priority_label
    assert_equal "Medium",    tasks(:todo_task).priority_label
    assert_equal "Very High", tasks(:high_priority_task).priority_label
  end

  test "priority_css returns formatted css class" do
    assert_equal "priority--high",      tasks(:in_progress_task).priority_css
    assert_equal "priority--very-high", tasks(:high_priority_task).priority_css
  end

  # ── Scopes ────────────────────────────────────────────────────────────────

  test "by_status filters tasks to the given status" do
    todos = Task.by_status("todo")
    assert todos.all? { |t| t.status == "todo" }
    assert_not todos.empty?
  end

  test "by_status with nil returns all tasks" do
    assert_equal Task.count, Task.by_status(nil).count
  end

  test "by_status with blank string returns all tasks" do
    assert_equal Task.count, Task.by_status("").count
  end

  test "ordered scope places higher-priority tasks before lower ones" do
    very_high = tasks(:high_priority_task)  # priority: very_high, status: todo
    medium    = tasks(:todo_task)           # priority: medium,    status: todo

    ordered_ids = Task.where(status: "todo").ordered.pluck(:id)
    assert ordered_ids.index(very_high.id) < ordered_ids.index(medium.id)
  end

  # ── Associations ──────────────────────────────────────────────────────────

  test "creator is optional" do
    assert build_task.valid?
  end

  test "assignee is optional" do
    assert build_task.valid?
  end

  test "destroying a task also destroys its comments" do
    task = tasks(:todo_task)
    assert task.comments.any?
    assert_difference "Comment.count", -task.comments.count do
      task.destroy
    end
  end
end
