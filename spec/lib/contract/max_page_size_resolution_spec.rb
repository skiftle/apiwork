# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Max page size resolution priority' do
  describe 'configuration resolution in page descriptor' do
    it 'uses API default when no override' do
      api = Apiwork::API.draw '/test/default' do
        resources :posts
      end

      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'Test::Default::PostContract'
        end

        action :index do
          input do
            param :page, type: :page, required: false
          end
        end
      end

      # Manually set api_class since we can't rely on namespace detection
      allow(contract).to receive(:api_class).and_return(api)

      definition = contract.action_definition(:index).merged_input_definition
      page_param = definition.params[:page]
      page_size_max = page_param[:shape].params[:size][:max]

      expect(page_size_max).to eq(200) # API default
    end

    it 'uses API configured max_page_size' do
      api = Apiwork::API.draw '/test/api_config' do
        configure do
          max_page_size 100
        end

        resources :posts
      end

      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'Test::ApiConfig::PostContract'
        end

        action :index do
          input do
            param :page, type: :page, required: false
          end
        end
      end

      allow(contract).to receive(:api_class).and_return(api)

      definition = contract.action_definition(:index).merged_input_definition
      page_param = definition.params[:page]
      page_size_max = page_param[:shape].params[:size][:max]

      expect(page_size_max).to eq(100) # API configured
    end

    it 'schema override takes priority over API' do
      api = Apiwork::API.draw '/test/schema_override' do
        configure do
          max_page_size 100
        end

        resources :posts
      end

      schema = Class.new(Apiwork::Schema::Base) do
        def self.name
          'Test::SchemaOverride::PostSchema'
        end

        configure do
          max_page_size 50
        end
      end

      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'Test::SchemaOverride::PostContract'
        end

        schema schema

        action :index do
          input do
            param :page, type: :page, required: false
          end
        end
      end

      allow(contract).to receive(:api_class).and_return(api)

      definition = contract.action_definition(:index).merged_input_definition
      page_param = definition.params[:page]
      page_size_max = page_param[:shape].params[:size][:max]

      expect(page_size_max).to eq(50) # Schema overrides API
    end

    it 'contract override has highest priority' do
      api = Apiwork::API.draw '/test/contract_override' do
        configure do
          max_page_size 100
        end

        resources :posts
      end

      schema = Class.new(Apiwork::Schema::Base) do
        def self.name
          'Test::ContractOverride::PostSchema'
        end

        configure do
          max_page_size 50
        end
      end

      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'Test::ContractOverride::PostContract'
        end

        schema schema

        configure do
          max_page_size 25
        end

        action :index do
          input do
            param :page, type: :page, required: false
          end
        end
      end

      allow(contract).to receive(:api_class).and_return(api)

      definition = contract.action_definition(:index).merged_input_definition
      page_param = definition.params[:page]
      page_size_max = page_param[:shape].params[:size][:max]

      expect(page_size_max).to eq(25) # Contract has highest priority
    end
  end
end
