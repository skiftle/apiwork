# frozen_string_literal: true

module RuboCop
  module Cop
    module Apiwork
      class SortAttrArguments < Base
        extend AutoCorrector

        MSG = 'Sort attr_* arguments alphabetically and put each on its own line.'

        TARGET_METHODS = %i[attr_reader attr_accessor attr_writer].freeze

        def on_send(node)
          return unless TARGET_METHODS.include?(node.method_name)

          args = node.arguments
          return unless args.size > 1
          return unless args.all?(&:sym_type?)
          return unless single_line?(node)

          add_offense(node.loc.selector) do |corrector|
            sorted_names = args.map { |arg| arg.value.to_s }.sort
            replacement  = build_multiline(node, sorted_names)

            corrector.replace(node.loc.expression, replacement)
          end
        end

        private

        def single_line?(node)
          expr = node.loc.expression
          expr.first_line == expr.last_line
        end

        def build_multiline(node, sorted_names)
          indent = ' ' * node.loc.column
          method_name = node.method_name.to_s
          base_prefix = "#{indent}#{method_name} "
          cont_indent = ' ' * base_prefix.length

          lines = []

          sorted_names.each_with_index do |name, index|
            lines << if index.zero?
                       "#{base_prefix}:#{name},"
                     else
                       "#{cont_indent}:#{name},"
                     end
          end

          lines[-1] = lines[-1].sub(/,$/, '')

          lines.join("\n")
        end
      end
    end
  end
end
