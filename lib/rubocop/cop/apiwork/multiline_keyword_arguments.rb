# frozen_string_literal: true

module RuboCop
  module Cop
    module Apiwork
      class MultilineKeywordArguments < Base
        extend AutoCorrector

        MSG_SPLIT = 'Use multiline keyword arguments when there are more than %<max>d.'
        MSG_SPLIT_LENGTH = 'Use multiline keyword arguments when line exceeds %<max>d characters.'
        MSG_COLLAPSE = 'Collapse keyword arguments to single line when there are %<max>d or fewer.'

        def on_send(node)
          return unless dsl_method?(node)
          return if node.receiver

          kwargs = extract_kwargs(node)
          return if kwargs.nil?

          if single_line_call?(node) && should_split?(node, kwargs)
            message = kwargs.size > max_on_line ? format(MSG_SPLIT, max: max_on_line) : format(MSG_SPLIT_LENGTH, max: max_line_length)
            add_offense(node, message: message) do |corrector|
              corrector.replace(node.source_range, rebuild_multiline(node, kwargs))
            end
          elsif multiline_call?(node) && kwargs.size <= max_on_line && !would_exceed_line_length?(node, kwargs)
            add_offense(node, message: format(MSG_COLLAPSE, max: max_on_line)) do |corrector|
              corrector.replace(correction_range(node), rebuild_single_line(node, kwargs))
            end
          end
        end

        private

        def should_split?(node, kwargs)
          kwargs.size > max_on_line || exceeds_line_length?(node)
        end

        def exceeds_line_length?(node)
          node.source_range.source.length + node.loc.column > max_line_length
        end

        def dsl_method?(node)
          methods.include?(node.method_name.to_s)
        end

        def methods
          cop_config['Methods'] || []
        end

        def max_on_line
          cop_config['MaxOneLine'] || 4
        end

        def single_line_call?(node)
          if has_own_block?(node)
            node.loc.line == node.parent.loc.begin.line
          else
            node.loc.first_line == node.loc.last_line
          end
        end

        def multiline_call?(node)
          !single_line_call?(node)
        end

        def would_exceed_line_length?(node, kwargs)
          single_line = rebuild_single_line(node, kwargs)
          total_length = node.loc.column + single_line.length
          total_length > max_line_length
        end

        def max_line_length
          config.for_cop('Layout/LineLength')['Max'] || 120
        end

        def has_own_block?(node)
          node.parent&.block_type? && node.parent.children.first == node
        end

        def correction_range(node)
          if has_own_block?(node)
            node.source_range.join(node.parent.loc.begin)
          else
            node.source_range
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

        def rebuild_single_line(node, kwargs)
          positional_args = extract_positional_args(node)
          kwargs_str = kwargs.map(&:source).join(', ')

          result = if positional_args.empty?
                     "#{node.method_name} #{kwargs_str}"
                   else
                     "#{node.method_name} #{positional_args.map(&:source).join(', ')}, #{kwargs_str}"
                   end

          result += ' do' if has_own_block?(node)
          result
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
