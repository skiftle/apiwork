# frozen_string_literal: true

module RuboCop
  module Cop
    module Apiwork
      class SortHashKeys < Base
        extend AutoCorrector

        MSG = 'Sort hash keys alphabetically.'

        def on_hash(node)
          return unless processable?(node)

          pairs = node.pairs
          return if pairs.size < 2

          sorted_keys = pairs.map { |p| key_name(p) }.sort
          actual_keys = pairs.map { |p| key_name(p) }
          return if sorted_keys == actual_keys

          add_offense(node) do |corrector|
            corrector.replace(content_range(node), rebuild_pairs(node, sorted_keys))
          end
        end

        private

        def processable?(node)
          pairs = node.pairs
          return false if pairs.empty?
          return false unless all_symbol_keys?(pairs)
          return false if has_kwsplat?(node)
          return false if has_duplicate_keys?(pairs)
          return false unless single_line?(node)

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

        def single_line?(node)
          node.loc.expression.first_line == node.loc.expression.last_line
        end

        def key_name(pair)
          pair.key.value.to_s
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

        def rebuild_pairs(node, sorted_keys)
          pairs_hash = node.pairs.each_with_object({}) do |pair, h|
            h[key_name(pair)] = pair.source
          end

          content = sorted_keys.map { |k| pairs_hash[k] }.join(', ')

          node.loc.begin ? " #{content} " : content
        end
      end
    end
  end
end
