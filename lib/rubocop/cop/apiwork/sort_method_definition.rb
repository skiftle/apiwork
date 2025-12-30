# frozen_string_literal: true

module RuboCop
  module Cop
    module Apiwork
      # Enforces sorted keyword arguments in method definitions.
      #
      # Only applies to single-line kwargs. Multiline kwargs are ignored
      # to preserve intentional formatting.
      #
      # @example
      #   # bad
      #   def foo(zebra:, alpha:)
      #
      #   # good (sorted)
      #   def foo(alpha:, zebra:)
      class SortMethodDefinition < Base
        extend AutoCorrector

        MSG = 'Sort keyword arguments alphabetically.'

        def on_def(node)
          check_method_definition(node)
        end

        def on_defs(node)
          check_method_definition(node)
        end

        private

        def check_method_definition(node)
          kwargs = extract_kwargs(node.arguments)
          return if kwargs.size < 2
          return if has_kwrestarg?(node.arguments)
          return unless single_line?(kwargs)

          sorted_names = kwargs.map { |arg| arg.name.to_s }.sort
          actual_names = kwargs.map { |arg| arg.name.to_s }

          return if sorted_names == actual_names

          add_offense(node.loc.keyword) do |corrector|
            replace_range = kwargs_range(kwargs)
            corrector.replace(replace_range, rebuild_kwargs(node.arguments, sorted_names))
          end
        end

        def extract_kwargs(args)
          args.select { |arg| arg.kwoptarg_type? || arg.kwarg_type? }
        end

        def has_kwrestarg?(args)
          args.any?(&:kwrestarg_type?)
        end

        def single_line?(items)
          return true if items.empty?

          items.first.loc.line == items.last.loc.line
        end

        def kwargs_range(kwargs)
          Parser::Source::Range.new(
            kwargs.first.loc.expression.source_buffer,
            kwargs.first.loc.expression.begin_pos,
            kwargs.last.loc.expression.end_pos,
          )
        end

        def rebuild_kwargs(args, sorted_names)
          kwargs_hash = {}

          args.each do |arg|
            next unless arg.kwoptarg_type? || arg.kwarg_type?

            kwargs_hash[arg.name.to_s] = arg.source
          end

          sorted_names.map { |name| kwargs_hash[name] }.join(', ')
        end
      end
    end
  end
end
