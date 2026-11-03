# frozen_string_literal: true

require_relative '../../prose/code_rules'

module RuboCop
  module Cop
    module Markdown
      class CodeBlockStyle < Prose::Base
        extend AutoCorrector
        include RuboCop::Prose::CodeRules

        private

        def investigate_document
          expected = cop_config.fetch('EnforcedStyle', 'consistent')
          code_blocks.each do |node|
            actual = node.options[:fenced] ? 'fenced' : 'indented'
            expected = actual if expected == 'consistent'
            next if actual == expected

            range = document.line_range(node.options[:location])
            prose_offense(range, message: "Use #{expected} code blocks.") do |corrector|
              conversion = safe_conversion(node, expected)
              corrector.replace(processed_range(conversion.first), conversion.last) if conversion
            end
          end
        end

        def safe_conversion(node, expected)
          return unless code_ancestors(node).all? { |ancestor| ancestor.type == :root }

          expected == 'fenced' ? to_fenced(node) : to_indented(node)
        end

        def to_fenced(node)
          first = node.options.fetch(:code_start_line)
          last = first + node.value.lines.length - 1
          return if last < first || !code_blank?(first - 1) || !code_blank?(last + 1)

          raw = document.lines[(first - 1)..(last - 1)]
          return unless raw.all? { |line| line.start_with?('    ') || line.empty? }
          return unless "#{raw.map { |line| line.delete_prefix('    ') }.join("\n")}\n" == node.value

          length = [3, node.value.scan(/`+/).map(&:length).max.to_i + 1].max
          fence = '`' * length
          [document.range(first, 0, last), "#{fence}\n#{node.value}#{fence}"]
        end

        def to_indented(node)
          details = fence_details(node)
          return unless details && details[:opening][:prefix].empty? && details[:opening][:info].strip.empty?
          return unless details[:closing][:prefix].empty?
          return unless code_blank?(details[:first] - 1) && code_blank?(details[:last] + 1)
          return if adjacent_code_block?(node, details)

          body = document.lines[details[:first]...(details[:last] - 1)]
          return if body.empty? || body.first.strip.empty? || body.last.strip.empty?
          return unless "#{body.join("\n")}\n" == node.value

          [document.range(details[:first], 0, details[:last]),
           body.map { |line| line.empty? ? '' : "    #{line}" }.join("\n")]
        end

        def adjacent_code_block?(node, details)
          blocks = code_blocks
          index = blocks.index(node)
          neighbors = []
          neighbors << blocks[index - 1] if index.positive?
          neighbors << blocks[index + 1] if index + 1 < blocks.length
          neighbors.any? do |other|
            first = other.options[:location]
            last = other.options[:code_start_line] + other.value.lines.length - (other.options[:fenced] ? 0 : 1)
            gap = last < details[:first] ? ((last + 1)...details[:first]) : ((details[:last] + 1)...first)
            gap.all? { |number| document.line(number).strip.empty? }
          end
        end
      end
    end
  end
end
