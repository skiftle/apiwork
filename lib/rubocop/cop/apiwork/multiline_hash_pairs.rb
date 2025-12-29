# frozen_string_literal: true

module RuboCop
  module Cop
    module Apiwork
      class MultilineHashPairs < Base
        extend AutoCorrector

        MSG = 'Hash with %<count>d pairs should have one pair per line.'

        def on_hash(node)
          pairs = node.pairs
          return if pairs.size < min_pairs
          return if already_multiline_formatted?(node)
          return unless node.loc.begin

          add_offense(node, message: format(MSG, count: pairs.size)) do |corrector|
            corrector.replace(node.loc.expression, rebuild_multiline(node))
          end
        end

        private

        def min_pairs
          cop_config['MinPairs'] || 3
        end

        def already_multiline_formatted?(node)
          return false if single_line?(node)

          pairs = node.pairs
          return true if pairs.empty?

          lines = pairs.map { |p| p.loc.expression.first_line }
          lines.uniq.size == pairs.size
        end

        def single_line?(node)
          node.loc.expression.first_line == node.loc.expression.last_line
        end

        def rebuild_multiline(node)
          pairs = node.pairs
          line_indent = line_indentation(node)
          pair_indent = "#{line_indent}  "

          lines = ["{\n"]
          pairs.each_with_index do |pair, index|
            comma = index < pairs.size - 1 ? ',' : ''
            lines << "#{pair_indent}#{pair.source}#{comma}\n"
          end
          lines << "#{line_indent}}"

          lines.join
        end

        def line_indentation(node)
          source_line = node.loc.expression.source_buffer.source_line(node.loc.line)
          source_line[/\A\s*/]
        end
      end
    end
  end
end
