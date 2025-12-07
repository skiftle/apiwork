# frozen_string_literal: true

module BraveEagle
  class TasksController < ApplicationController
    before_action :set_task, only: %i[show update destroy archive]

    def index
      tasks = Task.all
      respond_with tasks
    end

    def show
      respond_with task
    end

    def create
      task = Task.create(contract.body[:task])
      respond_with task
    end

    def update
      task.update(contract.body[:task])
      respond_with task
    end

    def destroy
      task.destroy
      respond_with task
    end

    def archive
      task.archive!
      respond_with task
    end

    private

    attr_reader :task

    def set_task
      @task = Task.find(params[:id])
    end
  end
end
