# frozen_string_literal: true

module Api
  module V1
    # PersonsController - Controller using PersonResource
    # Demonstrates irregular plural root keys (person/people)
    class PersonsController < ApplicationController
      include Apiwork::Controller

      def index
        render_with_contract Post.all
      end

      def show
        person = Post.find(params[:id])
        render_with_contract person
      end

      def create
        person = Post.new(contract.body[:person])
        person.save
        render_with_contract person
      end

      def update
        person = Post.find(params[:id])
        person.update(contract.body[:person])
        render_with_contract person
      end

      def destroy
        person = Post.find(params[:id])
        person.destroy
        render_with_contract person
      end
    end
  end
end
