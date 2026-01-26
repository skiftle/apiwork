# frozen_string_literal: true

module WiseTiger
  class ProjectContract < Apiwork::Contract::Base
    representation ProjectRepresentation

    action :index do
      tags 'Projects'
      operation_id 'listProjects'
    end

    action :show do
      tags 'Projects'
      operation_id 'getProject'
    end

    action :create do
      tags 'Projects'
      operation_id 'createProject'
    end

    action :update do
      tags 'Projects'
      operation_id 'updateProject'
    end

    action :destroy do
      tags 'Projects'
      operation_id 'deleteProject'
    end
  end
end
