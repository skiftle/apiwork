# frozen_string_literal: true

module Apiwork
  module Adapter
    module Envelope
      class Base
        def define(registrar, **options); end

        def render(*)
          raise NotImplementedError
        end
      end
    end
  end
end
