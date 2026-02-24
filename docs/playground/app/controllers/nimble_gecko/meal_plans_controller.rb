# frozen_string_literal: true

module NimbleGecko
  class MealPlansController < ApplicationController
    before_action :set_meal_plan, only: %i[show update destroy]

    def index
      meal_plans = MealPlan.all
      expose meal_plans
    end

    def show
      expose meal_plan
    end

    def create
      meal_plan = MealPlan.create(contract.body[:meal_plan])
      expose meal_plan
    end

    def update
      meal_plan.update(contract.body[:meal_plan])
      expose meal_plan
    end

    def destroy
      meal_plan.destroy
      expose meal_plan
    end

    private

    attr_reader :meal_plan

    def set_meal_plan
      @meal_plan = MealPlan.find(params[:id])
    end
  end
end
