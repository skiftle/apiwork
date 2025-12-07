# frozen_string_literal: true

module WiseTiger
  class ProjectsController < ApplicationController
    before_action :set_project, only: %i[show update destroy]

    def index
      projects = Project.all
      respond_with projects
    end

    def show
      respond_with project
    end

    def create
      project = Project.create(contract.body[:project])
      respond_with project
    end

    def update
      project.update(contract.body[:project])
      respond_with project
    end

    def destroy
      project.destroy
      respond_with project
    end

    private

    attr_reader :project

    def set_project
      @project = Project.find(params[:id])
    end
  end
end
