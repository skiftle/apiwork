# frozen_string_literal: true

require "fileutils"
require "json"
require "yaml"

module Docs
  class ExampleGenerator
    EXAMPLES_DIR = Rails.root.join("../examples")

    def self.run
      new.generate_all
    end

    def generate_all
      puts "Generating documentation examples..."

      FileUtils.rm_rf(EXAMPLES_DIR)
      FileUtils.mkdir_p(EXAMPLES_DIR)

      Apiwork::API.all.each do |api|
        generate_for_api(api)
      end

      puts "Done!"
    end

    private

    def generate_for_api(api)
      namespace = api.metadata.path.delete_prefix("/")
      output_dir = EXAMPLES_DIR.join(namespace)
      FileUtils.mkdir_p(output_dir)

      puts "  Generating: #{namespace}/"

      write_typescript(api, output_dir)
      write_zod(api, output_dir)
      write_openapi(api, output_dir)
      write_introspection(api, output_dir)
      write_output_example(api, output_dir)
    end

    def write_typescript(api, dir)
      content = Apiwork::Spec::Typescript.generate(path: api.metadata.path)
      File.write(dir.join("typescript.ts"), content)
    end

    def write_zod(api, dir)
      content = Apiwork::Spec::Zod.generate(path: api.metadata.path)
      File.write(dir.join("zod.ts"), content)
    end

    def write_openapi(api, dir)
      content = Apiwork::Spec::Openapi.generate(path: api.metadata.path)
      File.write(dir.join("openapi.yml"), content.to_yaml)
    end

    def write_introspection(api, dir)
      content = api.introspect
      File.write(dir.join("introspection.json"), JSON.pretty_generate(content))
    end

    def write_output_example(api, dir)
      resource_name = api.metadata.resources.keys.first
      example = build_example_response(resource_name)
      File.write(dir.join("output.json"), JSON.pretty_generate(example))
    end

    def build_example_response(resource_name)
      singular = resource_name.to_s.singularize

      {
        resource_name => [
          sample_record(singular, 1),
          sample_record(singular, 2)
        ],
        pagination: {
          current: 1,
          total: 2,
          items: 2,
          prev: nil,
          next: nil
        }
      }
    end

    def sample_record(type, index)
      uuid = format("f47ac10b-58cc-4372-a567-0e02b2c3d%03d", index)

      case type
      when "invoice"
        {
          id: uuid,
          number: "INV-2024-#{format('%03d', index)}",
          issued_on: "2024-03-#{format('%02d', index + 14)}",
          status: index == 1 ? "paid" : "pending",
          notes: index == 1 ? "Payment received" : nil,
          created_at: "2024-03-01T10:30:00Z",
          updated_at: "2024-03-20T14:45:00Z",
          customer: {
            id: "a1b2c3d4-e5f6-7890-abcd-ef123456789#{index}",
            name: index == 1 ? "Acme Corporation" : "Tech Startup Inc"
          },
          lines: [
            {
              id: "11111111-2222-3333-4444-55555555555#{index}",
              description: "Consulting services",
              quantity: 10,
              price: "150.00"
            }
          ]
        }
      else
        {
          id: uuid,
          created_at: "2024-03-01T10:30:00Z",
          updated_at: "2024-03-20T14:45:00Z"
        }
      end
    end
  end
end
