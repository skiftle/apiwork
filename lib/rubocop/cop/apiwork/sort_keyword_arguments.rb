# frozen_string_literal: true

module RuboCop
  module Cop
    module Apiwork
      class SortKeywordArguments < Base
        extend AutoCorrector

        MSG = 'Sort keyword arguments alphabetically.'

        def on_def(node)
          check_method_definition(node)
        end

        def on_defs(node)
          check_method_definition(node)
        end

        def on_send(node)
          check_method_call(node)
        end

        private

        # Method definitions: def foo(a:, b:)
        def check_method_definition(node)
          kwargs = extract_def_kwargs(node.arguments)
          return if kwargs.size < 2
          return if has_kwrestarg?(node.arguments)
          return unless single_line?(kwargs)

          sorted_names = kwargs.map { |arg| arg.name.to_s }.sort
          actual_names = kwargs.map { |arg| arg.name.to_s }
          return if sorted_names == actual_names

          add_offense(node.loc.keyword) do |corrector|
            replace_range = kwargs_range(kwargs)
            corrector.replace(replace_range, rebuild_def_kwargs(node.arguments, sorted_names))
          end
        end

        # Method calls: foo(a: 1, b: 2)
        def check_method_call(node)
          return if node.receiver

          pairs = extract_call_kwargs(node)
          return if pairs.nil? || pairs.size < 2
          return if has_kwsplat?(node)

          sorted_keys = pairs.map { |p| p.key.source.to_s }.sort
          actual_keys = pairs.map { |p| p.key.source.to_s }
          return if sorted_keys == actual_keys

          add_offense(node) do |corrector|
            sorted_pairs = pairs.sort_by { |p| p.key.source.to_s }
            if single_line?(pairs)
              corrector.replace(kwargs_range(pairs), sorted_pairs.map(&:source).join(', '))
            else
              rebuild_multiline_call_kwargs(corrector, pairs, sorted_pairs)
            end
          end
        end

        def extract_def_kwargs(args)
          args.select { |arg| arg.kwoptarg_type? || arg.kwarg_type? }
        end

        def extract_call_kwargs(node)
          return nil if node.arguments.empty?

          last_arg = node.arguments.last
          return last_arg.pairs if last_arg.hash_type? && last_arg.pairs.any?

          nil
        end

        def has_kwrestarg?(args)
          args.any?(&:kwrestarg_type?)
        end

        def has_kwsplat?(node)
          return false if node.arguments.empty?

          last_arg = node.arguments.last
          return false unless last_arg.hash_type?

          last_arg.children.any?(&:kwsplat_type?)
        end

        def single_line?(items)
          return true if items.empty?

          items.first.loc.line == items.last.loc.line
        end

        def kwargs_range(items)
          Parser::Source::Range.new(
            items.first.loc.expression.source_buffer,
            items.first.loc.expression.begin_pos,
            items.last.loc.expression.end_pos,
          )
        end

        def rebuild_def_kwargs(args, sorted_names)
          kwargs_hash = {}

          args.each do |arg|
            next unless arg.kwoptarg_type? || arg.kwarg_type?

            kwargs_hash[arg.name.to_s] = arg.source
          end

          sorted_names.map { |name| kwargs_hash[name] }.join(', ')
        end

        def rebuild_multiline_call_kwargs(corrector, original_pairs, sorted_pairs)
          sorted_pairs.each_with_index do |sorted_pair, index|
            original_pair = original_pairs[index]
            next if original_pair == sorted_pair

            corrector.replace(original_pair.loc.expression, sorted_pair.source)
          end
        end
      end
    end
  end
end
