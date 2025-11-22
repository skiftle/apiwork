# frozen_string_literal: true

module Api
  module OverrideTest
    class OverrideTestController < ApplicationController
      include Apiwork::Controller::Concern
    end
  end
end
