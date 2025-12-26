# frozen_string_literal: true

module WiseTiger
  class ProjectsController < ApplicationController
    before_action :set_project, only: %i[show update destroy]

    def index
      projects = Project.all
      expose projects
    end

    def show
      expose project
    end

    def create
      project = Project.create(contract.body[:project])
      expose project
    end

    def update
      project.update(contract.body[:project])
      expose project
    end

    def destroy
      project.destroy
      expose project
    end

    private

    attr_reader :project

    def set_project
      @project = Project.find(params[:id])
    end
  end
end
