# frozen_string_literal: true

module Api
  module V1
    # PersonsController - Controller using PersonResource
    # Demonstrates irregular plural root keys (person/people)
    class PersonsController < ApplicationController
      include Apiwork::Controller

      def index
        expose Post.all
      end

      def show
        person = Post.find(params[:id])
        expose person
      end

      def create
        person = Post.new(contract.body[:person])
        person.save
        expose person
      end

      def update
        person = Post.find(params[:id])
        person.update(contract.body[:person])
        expose person
      end

      def destroy
        person = Post.find(params[:id])
        person.destroy
        expose person
      end
    end
  end
end
