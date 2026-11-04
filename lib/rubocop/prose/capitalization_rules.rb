# frozen_string_literal: true

require_relative 'inline_rules'

module RuboCop
  module Prose
    module CapitalizationRules
      WORD = /[\p{L}\p{N}][\p{L}\p{M}\p{N}_]*(?:['’][\p{L}\p{M}\p{N}_]+)*/

      def validate_config
        styles = cop_config['SupportedStyles']
        unless styles.include?(cop_config['EnforcedStyle'])
          raise RuboCop::ValidationError, "#{cop_name}: EnforcedStyle must be one of #{styles.join(', ')}."
        end

        %w[IgnoredWords MinorWords].each do |option|
          words = cop_config[option]
          next if words.is_a?(Array) && words.all? { |word| word.is_a?(String) && word.match?(/\A#{WORD}\z/) }

          raise RuboCop::ValidationError, "#{cop_name}: #{option} must be an array of individual words."
        end
        return if [true, false].include?(cop_config['PreserveMixedCase'])

        raise RuboCop::ValidationError, "#{cop_name}: PreserveMixedCase must be true or false."
      end

      private

      def correction_range(text, number)
        return if text.empty? || text.include?("\n") || text.include?("\0")

        source = document.line(number)
        first = source.index(text)
        return unless first && !source.index(text, first + 1)

        last = first + text.length
        protected = InlineRules.spans(source)
        return if protected.any? { |span| first < span.end_pos && last > span.begin_pos }

        document.range(number, first, number, last)
      end

      def capitalized_text(text, title_case)
        words = text.scan(WORD).grep(/\p{L}/)
        minor_words = cop_config['MinorWords'].map(&:downcase)
        index = -1
        text.gsub(WORD) do |word|
          next word unless word.match?(/\p{L}/)

          index += 1
          next word if ignored_word?(word) || (!title_case && index.positive?)

          if title_case && index.positive? && index < words.size - 1 && minor_words.include?(word.downcase)
            word.downcase
          elsif invalid_initial?(word)
            word.sub(/\p{L}/, &:upcase)
          else
            word
          end
        end
      end

      def invalid_initial?(text)
        first = /[\p{L}\0]/.match(text)
        return false unless first && first[0].match?(/\p{Ll}/)
        return false if ignored_word?(text.scan(WORD).find { |word| word.match?(/\p{L}/) })

        word = text[first.begin(0)..][/\A[\p{L}\p{N}_]+/]
        !cop_config['PreserveMixedCase'] || !word&.match?(/\p{Lu}|\p{Lt}/)
      end

      def invalid_title?(text)
        return false if text.include?("\0")

        words = text.scan(WORD).grep(/\p{L}/)
        minor_words = cop_config['MinorWords'].map(&:downcase)
        words.each_with_index.any? do |word, index|
          next false if ignored_word?(word)

          if index.positive? && index < words.size - 1 && minor_words.include?(word.downcase)
            word != word.downcase
          else
            invalid_initial?(word)
          end
        end
      end

      def ignored_word?(word)
        cop_config['IgnoredWords'].include?(word)
      end

      def prose_text(node)
        case node.type
        when :text then node.value.to_s
        when :entity then node.value.char
        when :header, :p, :em, :strong, :a
          node.children.map { |child| prose_text(child) }.join
        else
          # Do not check a later word after opaque leading content.
          "\0"
        end
      end
    end
  end
end
