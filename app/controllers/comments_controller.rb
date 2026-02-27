class CommentsController < ApplicationController
  before_action :set_task

  def create
    @comment = @task.comments.build(comment_params)
    if @comment.save
      redirect_to @task, notice: "Note added."
    else
      redirect_to @task, alert: "Note can't be blank."
    end
  end

  def destroy
    @comment = @task.comments.find(params[:id])
    @comment.destroy
    redirect_to @task, notice: "Note deleted."
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
