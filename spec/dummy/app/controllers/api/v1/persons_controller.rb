# frozen_string_literal: true

module Api
  module V1
    # PersonsController - Controller using PersonResource
    # Demonstrates irregular plural root keys (person/people)
    class PersonsController < ApplicationController
      include Apiwork::Controller::Concern

      def index
        respond_with Post.all
      end

      def show
        person = Post.find(params[:id])
        respond_with person
      end

      def create
        person = Post.new(action_params)
        person.save
        respond_with person
      end

      def update
        person = Post.find(params[:id])
        person.update(action_params)
        respond_with person
      end

      def destroy
        person = Post.find(params[:id])
        person.destroy
        respond_with person
      end
    end
  end
end
