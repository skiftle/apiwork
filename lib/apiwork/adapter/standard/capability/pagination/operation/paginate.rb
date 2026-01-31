# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class Operation < Adapter::Capability::Operation::Base
            module Paginate
              class << self
                def apply(data, options, params)
                  case options.strategy
                  when :offset then Offset.apply(data, options, params)
                  when :cursor then Cursor.apply(data, options, params)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
