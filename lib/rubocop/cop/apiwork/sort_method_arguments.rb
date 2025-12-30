# frozen_string_literal: true

module RuboCop
  module Cop
    module Apiwork
      # Enforces sorted symbol arguments in method calls.
      #
      # Applies to methods like attr_reader, attr_accessor, delegate.
      # Sorts symbol arguments alphabetically without changing structure.
      # Single-line calls stay single-line, multiline stay multiline.
      #
      # @example
      #   # bad
      #   attr_reader :zebra, :alpha
      #
      #   # good (sorted)
      #   attr_reader :alpha, :zebra
      #
      #   # bad (unsorted multiline)
      #   attr_reader :zebra,
      #               :alpha
      #
      #   # good (sorted multiline)
      #   attr_reader :alpha,
      #               :zebra
      class SortMethodArguments < Base
        extend AutoCorrector

        MSG = 'Sort symbol arguments alphabetically.'

        def on_send(node)
          return unless methods.include?(node.method_name.to_s)
          return if node.receiver

          symbol_args = node.arguments.select(&:sym_type?)
          return unless symbol_args.size > 1

          sorted_names = symbol_args.map { |arg| arg.value.to_s }.sort
          actual_names = symbol_args.map { |arg| arg.value.to_s }

          return if actual_names == sorted_names

          add_offense(node.loc.selector) do |corrector|
            corrector.replace(node.loc.expression, build_replacement(node, sorted_names))
          end
        end

        private

        def methods
          cop_config['Methods'] || []
        end

        def single_line?(node)
          expr = node.loc.expression
          expr.first_line == expr.last_line
        end

        def build_replacement(node, sorted_names)
          if single_line?(node)
            build_single_line(node, sorted_names)
          else
            build_multiline(node, sorted_names)
          end
        end

        def build_single_line(node, sorted_names)
          trailing_kwargs = node.arguments.reject(&:sym_type?)
          symbols = sorted_names.map { |name| ":#{name}" }.join(', ')

          if trailing_kwargs.empty?
            "#{node.method_name} #{symbols}"
          else
            kwargs = trailing_kwargs.map(&:source).join(', ')
            "#{node.method_name} #{symbols}, #{kwargs}"
          end
        end

        def build_multiline(node, sorted_names)
          method_name = node.method_name.to_s
          first_line_prefix = "#{method_name} "
          cont_indent = ' ' * (node.loc.column + first_line_prefix.length)

          lines = sorted_names.map.with_index do |name, index|
            prefix = index.zero? ? first_line_prefix : cont_indent
            comma = index < sorted_names.size - 1 ? ',' : ''
            "#{prefix}:#{name}#{comma}"
          end

          trailing_kwargs = node.arguments.reject(&:sym_type?)
          if trailing_kwargs.any?
            lines[-1] += ','
            trailing_kwargs.each do |kwarg|
              lines << "#{cont_indent}#{kwarg.source}"
            end
          end

          lines.join("\n")
        end
      end
    end
  end
end
