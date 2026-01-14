# frozen_string_literal: true

module RuboCop
  module Cop
    module Apiwork
      # Enforces sorted keyword arguments in method calls.
      #
      # Sorts keyword arguments alphabetically without changing structure.
      # Single-line calls stay single-line, multiline stay multiline.
      #
      # @example
      #   # bad
      #   attribute :name, zebra: true, alpha: false
      #
      #   # good (sorted)
      #   attribute :name, alpha: false, zebra: true
      #
      #   # bad (unsorted multiline)
      #   attribute :name,
      #             zebra: true,
      #             alpha: false
      #
      #   # good (sorted multiline)
      #   attribute :name,
      #             alpha: false,
      #             zebra: true
      class SortKeywords < Base
        extend AutoCorrector

        MSG = 'Sort keyword arguments alphabetically.'

        def on_send(node)
          return unless dsl_method?(node)
          return if node.receiver

          kwargs = extract_kwargs(node)
          return if kwargs.nil? || kwargs.size < 2

          sorted_kwargs = sort_pairs(kwargs)
          return if kwargs == sorted_kwargs

          add_offense(node) do |corrector|
            corrector.replace(kwargs_range(kwargs), rebuild(kwargs, sorted_kwargs))
          end
        end

        private

        def dsl_method?(node)
          methods.include?(node.method_name.to_s)
        end

        def methods
          cop_config['Methods'] || []
        end

        def extract_kwargs(node)
          return nil if node.arguments.empty?

          last_arg = node.arguments.last
          return last_arg.pairs if last_arg.hash_type? && last_arg.pairs.any?

          nil
        end

        def key_name(pair)
          pair.key.value.to_s
        end

        def sort_pairs(pairs)
          if shorthands_first?
            pairs.sort_by { |pair| [shorthand?(pair) ? 0 : 1, key_name(pair)] }
          else
            pairs.sort_by { |pair| key_name(pair) }
          end
        end

        def shorthands_first?
          cop_config['ShorthandsFirst'] == true
        end

        def shorthand?(pair)
          pair.source.match?(/\A\w+:\z/)
        end

        def kwargs_range(kwargs)
          Parser::Source::Range.new(
            kwargs.first.loc.expression.source_buffer,
            kwargs.first.loc.expression.begin_pos,
            kwargs.last.loc.expression.end_pos,
          )
        end

        def rebuild(original_kwargs, sorted_kwargs)
          if multiline?(original_kwargs)
            rebuild_multiline(original_kwargs, sorted_kwargs)
          else
            rebuild_single_line(sorted_kwargs)
          end
        end

        def multiline?(kwargs)
          kwargs.first.loc.line != kwargs.last.loc.line
        end

        def rebuild_single_line(sorted_kwargs)
          sorted_kwargs.map(&:source).join(', ')
        end

        def rebuild_multiline(original_kwargs, sorted_kwargs)
          first_pair = original_kwargs.first
          indent = ' ' * first_pair.loc.column

          sorted_kwargs.map.with_index do |pair, index|
            if index.zero?
              pair.source
            else
              "#{indent}#{pair.source}"
            end
          end.join(",\n")
        end
      end
    end
  end
end
