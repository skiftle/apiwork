# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Operation
        # @api public
        # Shape builder for operation metadata.
        #
        # Provides {#options} for accessing capability configuration,
        # plus all DSL methods from {API::Object} for defining structure.
        # Used by operations to define their metadata contribution.
        #
        # @example Add pagination metadata shape
        #   metadata_shape do
        #     reference :pagination
        #   end
        class MetadataShape
          class << self
            def apply(object, options)
              new(object, options).apply
            end
          end

          # @api public
          # The capability options for this metadata shape.
          #
          # @return [Configuration]
          attr_reader :options

          # @!method array(name, **options, &block)
          #   @api public
          #   @see API::Object#array
          # @!method array?(name, **options, &block)
          #   @api public
          #   @see API::Object#array?
          # @!method binary(name, **options)
          #   @api public
          #   @see API::Object#binary
          # @!method binary?(name, **options)
          #   @api public
          #   @see API::Object#binary?
          # @!method boolean(name, **options)
          #   @api public
          #   @see API::Object#boolean
          # @!method boolean?(name, **options)
          #   @api public
          #   @see API::Object#boolean?
          # @!method date(name, **options)
          #   @api public
          #   @see API::Object#date
          # @!method date?(name, **options)
          #   @api public
          #   @see API::Object#date?
          # @!method datetime(name, **options)
          #   @api public
          #   @see API::Object#datetime
          # @!method datetime?(name, **options)
          #   @api public
          #   @see API::Object#datetime?
          # @!method decimal(name, **options)
          #   @api public
          #   @see API::Object#decimal
          # @!method decimal?(name, **options)
          #   @api public
          #   @see API::Object#decimal?
          # @!method integer(name, **options)
          #   @api public
          #   @see API::Object#integer
          # @!method integer?(name, **options)
          #   @api public
          #   @see API::Object#integer?
          # @!method literal(name, value:, **options)
          #   @api public
          #   @see API::Object#literal
          # @!method merge(other)
          #   @api public
          #   @see API::Object#merge
          # @!method number(name, **options)
          #   @api public
          #   @see API::Object#number
          # @!method number?(name, **options)
          #   @api public
          #   @see API::Object#number?
          # @!method object(name, **options, &block)
          #   @api public
          #   @see API::Object#object
          # @!method object?(name, **options, &block)
          #   @api public
          #   @see API::Object#object?
          # @!method reference(name, **options)
          #   @api public
          #   @see API::Object#reference
          # @!method reference?(name, **options)
          #   @api public
          #   @see API::Object#reference?
          # @!method string(name, **options)
          #   @api public
          #   @see API::Object#string
          # @!method string?(name, **options)
          #   @api public
          #   @see API::Object#string?
          # @!method time(name, **options)
          #   @api public
          #   @see API::Object#time
          # @!method time?(name, **options)
          #   @api public
          #   @see API::Object#time?
          # @!method union(name, **options, &block)
          #   @api public
          #   @see API::Object#union
          # @!method union?(name, **options, &block)
          #   @api public
          #   @see API::Object#union?
          # @!method uuid(name, **options)
          #   @api public
          #   @see API::Object#uuid
          # @!method uuid?(name, **options)
          #   @api public
          #   @see API::Object#uuid?
          delegate :array,
                   :array?,
                   :binary,
                   :binary?,
                   :boolean,
                   :boolean?,
                   :date,
                   :date?,
                   :datetime,
                   :datetime?,
                   :decimal,
                   :decimal?,
                   :integer,
                   :integer?,
                   :literal,
                   :merge,
                   :number,
                   :number?,
                   :object,
                   :object?,
                   :reference,
                   :reference?,
                   :string,
                   :string?,
                   :time,
                   :time?,
                   :union,
                   :union?,
                   :uuid,
                   :uuid?,
                   to: :object

          def initialize(object, options)
            @object = object
            @options = options
          end

          def apply
            raise NotImplementedError
          end

          private

          attr_reader :object
        end
      end
    end
  end
end
