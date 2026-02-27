class TasksController < ApplicationController
  before_action :set_task,  only: %i[show edit update destroy advance_status move]
  before_action :set_users, only: %i[show new edit create update]

  def index
    all_tasks = Task.includes(:creator, :assignee).ordered
    @tasks_by_status = Task::STATUSES.index_with { |s| all_tasks.select { |t| t.status == s } }
    @counts = @tasks_by_status.transform_values(&:count)
    @counts["all"] = all_tasks.count
  end

  def show
    @comment = Comment.new
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    @task.creator = current_user
    if @task.save
      redirect_to @task, notice: "Task created successfully."
    else
      flash.now[:alert] = @task.errors.full_messages.first
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @task.update(task_params)
      redirect_to @task, notice: "Task updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_path, notice: "Task deleted."
  end

  def move
    new_status = params[:status]
    unless Task::STATUSES.include?(new_status)
      return head :unprocessable_entity
    end

    if @task.update(status: new_status)
      head :ok
    else
      render json: { error: @task.errors.full_messages.first },
             status: :unprocessable_entity
    end
  end

  def advance_status
    next_label = Task::STATUS_LABELS[@task.next_status]
    @task.advance_status!
    redirect_to @task, notice: "Status advanced to \"#{next_label}\"."
  rescue => e
    redirect_to @task, alert: e.message
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def set_users
    @users = User.order(:nickname)
  end

  def task_params
    params.require(:task).permit(:title, :description, :priority, :assignee_id)
  end
end
