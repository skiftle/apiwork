# frozen_string_literal: true

module BraveEagle
  class TaskContract < Apiwork::Contract::Base
    schema!

    action :index do
      summary 'List all tasks'
      description 'Returns a paginated list of tasks with optional filtering by status and priority'
      tags 'Tasks', 'Core'
      operation_id 'listTasks'
    end

    action :show do
      summary 'Get task details'
      description 'Returns a single task by ID'
      tags 'Tasks'
      operation_id 'getTask'
    end

    action :create do
      summary 'Create a new task'
      description 'Creates a task and returns the created resource'
      tags 'Tasks'
      operation_id 'createTask'
    end

    action :update do
      summary 'Update a task'
      description 'Updates an existing task'
      tags 'Tasks'
      operation_id 'updateTask'
    end

    action :destroy do
      summary 'Delete a task'
      description 'Permanently removes a task'
      tags 'Tasks'
      operation_id 'deleteTask'
    end

    action :archive do
      summary 'Archive a task'
      description 'Marks a task as archived. Archived tasks are hidden from default listings but can still be retrieved.'
      tags 'Tasks', 'Lifecycle'
      operation_id 'archiveTask'
      deprecated
    end
  end
end
