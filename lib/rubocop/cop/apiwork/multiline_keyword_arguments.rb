# frozen_string_literal: true

module RuboCop
  module Cop
    module Apiwork
      class MultilineKeywordArguments < Base
        extend AutoCorrector

        MSG = 'Use multiline keyword arguments when there are more than two.'

        def on_send(node)
          return unless dsl_method?(node)
          return if node.receiver
          return unless single_line_call?(node)

          kwargs = extract_kwargs(node)
          return if kwargs.nil? || kwargs.size <= 2

          add_offense(node) do |corrector|
            corrector.replace(node.source_range, rebuild_multiline(node, kwargs))
          end
        end

        private

        def dsl_method?(node)
          methods.include?(node.method_name.to_s)
        end

        def methods
          cop_config['Methods'] || []
        end

        def single_line_call?(node)
          if node.parent&.block_type?
            block_node = node.parent
            node.loc.line == block_node.loc.begin.line
          else
            node.loc.first_line == node.loc.last_line
          end
        end

        def extract_kwargs(node)
          return nil if node.arguments.empty?

          last_arg = node.arguments.last
          return last_arg.pairs if last_arg.hash_type? && last_arg.pairs.any?

          nil
        end

        def rebuild_multiline(node, kwargs)
          base_indent = ' ' * node.loc.column
          continuation_indent = base_indent + (' ' * (node.method_name.length + 1))

          positional_args = extract_positional_args(node)
          first_line = build_first_line(node, positional_args)

          kwarg_lines = kwargs.map { |pair| "#{continuation_indent}#{pair.source}" }

          "#{first_line},\n#{kwarg_lines.join(",\n")}"
        end

        def extract_positional_args(node)
          return [] if node.arguments.empty?

          last_arg = node.arguments.last
          if last_arg.hash_type?
            node.arguments[0...-1]
          else
            node.arguments
          end
        end

        def build_first_line(node, positional_args)
          if positional_args.empty?
            node.method_name.to_s
          else
            "#{node.method_name} #{positional_args.map(&:source).join(', ')}"
          end
        end
      end
    end
  end
end
