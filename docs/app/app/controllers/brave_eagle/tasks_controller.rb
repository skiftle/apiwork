# frozen_string_literal: true

module BraveEagle
  class TasksController < ApplicationController
    before_action :set_task, only: %i[show update destroy archive]

    def index
      tasks = Task.all
      render_with_contract tasks
    end

    def show
      render_with_contract task
    end

    def create
      task = Task.create(contract.body[:task])
      render_with_contract task
    end

    def update
      task.update(contract.body[:task])
      render_with_contract task
    end

    def destroy
      task.destroy
      render_with_contract task
    end

    def archive
      task.archive!
      render_with_contract task
    end

    private

    attr_reader :task

    def set_task
      @task = Task.find(params[:id])
    end
  end
end
