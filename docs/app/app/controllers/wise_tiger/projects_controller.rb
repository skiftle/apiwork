# frozen_string_literal: true

module WiseTiger
  class ProjectsController < ApplicationController
    before_action :set_project, only: %i[show update destroy]

    def index
      projects = Project.all
      render_with_contract projects
    end

    def show
      render_with_contract project
    end

    def create
      project = Project.create(contract.body[:project])
      render_with_contract project
    end

    def update
      project.update(contract.body[:project])
      render_with_contract project
    end

    def destroy
      project.destroy
      render_with_contract project
    end

    private

    attr_reader :project

    def set_project
      @project = Project.find(params[:id])
    end
  end
end
