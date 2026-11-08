module Api
  class TasksController < ApplicationController
    before_action :set_task, only: %i[show update destroy]

    def index
      tasks = Task.includes(:category).order(:due_date, :id)
      tasks = tasks.where(category_id: params[:category_id]) if params[:category_id].present?
      tasks = tasks.where(status: params[:status]) if params[:status].present?
      tasks = tasks.where(priority: params[:priority]) if params[:priority].present?

      render json: tasks.map { |task| task_json(task) }
    end

    def show
      render json: task_json(@task)
    end

    def create
      task = Task.new(task_params)

      if task.save
        render json: task_json(task), status: :created
      else
        render json: { errors: task.errors.full_messages }, status: 422
      end
    end

    def update
      if @task.update(task_params)
        render json: task_json(@task)
      else
        render json: { errors: @task.errors.full_messages }, status: 422
      end
    end

    def destroy
      @task.destroy
      head :no_content
    end

    private

    def set_task
      @task = Task.find(params[:id])
    end

    def task_params
      params.expect(task: [ :title, :description, :status, :priority, :due_date, :category_id ])
    end

    def task_json(task)
      task.as_json.merge("category" => task.category.as_json(only: %i[id name]))
    end
  end
end
