# frozen_string_literal: true

module RuboCop
  module Cop
    module Apiwork
      class SortKeywordArguments < Base
        extend AutoCorrector

        MSG = 'Sort keyword arguments alphabetically.'

        def on_def(node)
          check_method(node)
        end

        def on_defs(node)
          check_method(node)
        end

        private

        def check_method(node)
          kwargs = extract_kwargs(node.arguments)
          return if kwargs.size < 2
          return if has_kwrestarg?(node.arguments)
          return unless single_line_kwargs?(kwargs)

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

        def single_line_kwargs?(kwargs)
          return true if kwargs.empty?

          kwargs.first.loc.line == kwargs.last.loc.line
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
