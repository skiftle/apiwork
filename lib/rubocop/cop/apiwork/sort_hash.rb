# frozen_string_literal: true

module RuboCop
  module Cop
    module Apiwork
      # Enforces sorted hash literals.
      #
      # Sorts hash keys alphabetically without changing structure.
      # Single-line hashes stay single-line, multiline stay multiline.
      #
      # @example
      #   # bad
      #   {b: 1, a: 2}
      #
      #   # good (sorted)
      #   {a: 2, b: 1}
      #
      #   # bad (unsorted multiline)
      #   {
      #     c: 3,
      #     a: 1,
      #     b: 2,
      #   }
      #
      #   # good (sorted multiline)
      #   {
      #     a: 1,
      #     b: 2,
      #     c: 3,
      #   }
      class SortHash < Base
        extend AutoCorrector

        MSG = 'Sort hash keys alphabetically.'

        def on_hash(node)
          return unless processable?(node)

          pairs = node.pairs
          return if pairs.size < 2

          sorted_pairs = sort_pairs(pairs)
          return if pairs == sorted_pairs

          add_offense(node) do |corrector|
            next if ancestor_unsorted_hash?(node)

            if already_multiline?(node)
              if implicit_kwargs?(node)
                corrector.replace(node.loc.expression, rebuild_multiline_implicit(node, sorted_pairs))
              else
                corrector.replace(node.loc.expression, rebuild_multiline(node, sorted_pairs))
              end
            else
              corrector.replace(content_range(node), rebuild_single_line(node, sorted_pairs))
            end
          end
        end

        private

        def processable?(node)
          pairs = node.pairs
          return false if pairs.empty?
          return false unless all_symbol_keys?(pairs)
          return false if has_kwsplat?(node)
          return false if has_duplicate_keys?(pairs)

          true
        end

        def all_symbol_keys?(pairs)
          pairs.all? { |pair| pair.key.sym_type? }
        end

        def has_kwsplat?(node)
          node.children.any? { |child| child.is_a?(Parser::AST::Node) && child.kwsplat_type? }
        end

        def has_duplicate_keys?(pairs)
          keys = pairs.map { |p| key_name(p) }
          keys.size != keys.uniq.size
        end

        def has_multiline_value?(pairs)
          pairs.any? { |pair| pair.value.loc.first_line != pair.value.loc.last_line }
        end

        def implicit_kwargs?(node)
          node.loc.begin.nil?
        end

        def single_line?(node)
          node.loc.expression.first_line == node.loc.expression.last_line
        end

        def already_multiline?(node)
          !single_line?(node)
        end

        def key_name(pair)
          pair.key.value.to_s
        end

        def sort_pairs(pairs)
          if shorthands_first?
            pairs.sort_by { |p| [shorthand?(p) ? 0 : 1, key_name(p)] }
          else
            pairs.sort_by { |p| key_name(p) }
          end
        end

        def shorthands_first?
          cop_config['ShorthandsFirst'] == true
        end

        def shorthand?(pair)
          pair.source.match?(/\A\w+:\z/)
        end

        def content_range(node)
          if node.loc.begin
            Parser::Source::Range.new(
              node.loc.expression.source_buffer,
              node.loc.begin.end_pos,
              node.loc.end.begin_pos,
            )
          else
            node.loc.expression
          end
        end

        def rebuild_single_line(node, sorted_pairs)
          content = sorted_pairs.map(&:source).join(', ')
          return content unless node.loc.begin

          original_content = content_range(node).source
          has_leading_space = original_content.start_with?(' ')
          has_trailing_space = original_content.end_with?(' ')

          result = content
          result = " #{result}" if has_leading_space
          result = "#{result} " if has_trailing_space
          result
        end

        def rebuild_multiline(node, sorted_pairs)
          indent = base_indentation(node)
          pair_indent = pair_indentation(node)

          lines = ["{\n"]
          sorted_pairs.each_with_index do |pair, index|
            trailing_comma = index < sorted_pairs.size - 1 || has_trailing_comma?(node)
            lines << "#{pair_indent}#{pair.source}#{trailing_comma ? ',' : ''}\n"
          end
          lines << "#{indent}}"

          lines.join
        end

        def rebuild_multiline_implicit(node, sorted_pairs)
          first_pair = node.pairs.first
          indent = ' ' * first_pair.loc.column

          sorted_pairs.map.with_index do |pair, index|
            if index.zero?
              pair.source
            else
              "#{indent}#{pair.source}"
            end
          end.join(",\n")
        end

        def base_indentation(node)
          source_line = node.loc.expression.source_buffer.source_line(node.loc.line)
          source_line[/\A\s*/]
        end

        def pair_indentation(node)
          first_pair = node.pairs.first
          source_line = first_pair.loc.expression.source_buffer.source_line(first_pair.loc.line)
          source_line[/\A\s*/]
        end

        def has_trailing_comma?(node)
          last_pair = node.pairs.last
          source_after_last = node.loc.expression.source[last_pair.loc.expression.end_pos - node.loc.expression.begin_pos..]
          source_after_last&.match?(/\A\s*,/)
        end

        def ancestor_unsorted_hash?(node)
          node.ancestors.any? do |ancestor|
            next false unless ancestor.hash_type?

            pairs = ancestor.pairs
            next false if pairs.size < 2
            next false unless all_symbol_keys?(pairs)
            next false if has_kwsplat?(ancestor)
            next false if has_duplicate_keys?(pairs)

            sort_pairs(pairs) != pairs
          end
        end
      end
    end
  end
end
