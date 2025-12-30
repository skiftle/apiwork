# frozen_string_literal: true

module RuboCop
  module Cop
    module Apiwork
      # Enforces Ruby 3 keyword shorthand (`foo(bar:)`) where a keyword argument
      # uses a local variable with the same name (`foo(bar: bar)`).
      #
      # Safe-by-design: only symbol keys and local variables with matching names
      # are considered. Comments on the same line are ignored to avoid unintended
      # changes.
      #
      # Requires TargetRubyVersion >= 3.1.
      #
      # @example
      #   # bad
      #   DomainIssueMapper.call(@record, locale_key: locale_key, root_path: root_path)
      #   options = { locale_key: locale_key, root_path: root_path }
      #
      #   # good
      #   DomainIssueMapper.call(@record, locale_key:, root_path:)
      #   options = { locale_key:, root_path: }
      #
      class KeywordShorthand < Base
        extend AutoCorrector

        MSG = 'Use Ruby 3 keyword shorthand `%<name>s:` instead of `%<name>s: %<name>s`.'

        def on_pair(node)
          return unless shorthand_candidate?(node)
          return if comment_on_line?(node)

          name = key_name(node)
          add_offense(node, message: format(MSG, name:)) do |corrector|
            corrector.replace(node.source_range, "#{name}:")
          end
        end

        private

        def shorthand_candidate?(node)
          return false unless node.colon?
          return false unless node.key.sym_type?
          return false unless node.value.lvar_type?
          return false unless key_name(node) == value_name(node)
          return false if already_shorthand?(node)
          return false if last_kwarg_before_modifier?(node)
          return false if last_kwarg_before_block?(node)

          true
        end

        def last_kwarg_before_modifier?(node)
          hash_node = node.parent
          return false unless hash_node&.hash_type?

          send_node = hash_node.parent
          return false unless send_node&.send_type? || send_node&.csend_type?

          parent_of_send = send_node.parent
          return false unless parent_of_send
          return false unless %i[if while until].include?(parent_of_send.type)
          return false unless parent_of_send.loc.respond_to?(:keyword) && parent_of_send.loc.keyword.source != 'elsif'

          modifier_form = parent_of_send.loc.respond_to?(:end) && parent_of_send.loc.end.nil?
          return false unless modifier_form

          node == hash_node.pairs.last
        end

        def last_kwarg_before_block?(node)
          hash_node = node.parent
          return false unless hash_node&.hash_type?

          send_node = hash_node.parent
          return false unless send_node&.send_type? || send_node&.csend_type?

          parent_of_send = send_node.parent
          return false unless parent_of_send&.block_type?

          node == hash_node.pairs.last
        end

        def already_shorthand?(node)
          node.source.strip.end_with?(':')
        end

        def key_name(node)
          node.key.value.to_s
        end

        def value_name(node)
          node.value.children.first.to_s
        end

        def comment_on_line?(node)
          line = node.loc.line
          processed_source.comments.any? { |comment| comment.loc.line == line }
        end
      end
    end
  end
end
