# frozen_string_literal: true

module BraveEagle
  class TasksController < ApplicationController
    before_action :set_task, only: %i[show update destroy archive]

    def index
      tasks = Task.all
      expose tasks
    end

    def show
      expose task
    end

    def create
      task = Task.create(contract.body[:task])
      expose task
    end

    def update
      task.update(contract.body[:task])
      expose task
    end

    def destroy
      task.destroy
      expose task
    end

    def archive
      task.archive!
      expose task
    end

    private

    attr_reader :task

    def set_task
      @task = Task.find(params[:id])
    end
  end
end
