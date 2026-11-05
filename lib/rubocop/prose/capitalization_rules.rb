# frozen_string_literal: true

require_relative 'inline_rules'

module RuboCop
  module Prose
    module CapitalizationRules
      WORD = /[\p{L}\p{N}][\p{L}\p{M}\p{N}_]*(?:['’][\p{L}\p{M}\p{N}_]+)*/
      OpeningWord = Struct.new(:word, :begin_pos, :end_pos, :literal, :code, keyword_init: true)
      QUOTES = { '"' => '"', "'" => "'", '“' => '”', '‘' => '’', '«' => '»', '‹' => '›',
                 '「' => '」', '『' => '』' }.freeze

      def opening_word(source, offset = 0, literal: false, depth: 0, base: 0, markdown: true)
        return if depth > 8

        index = offset
        index += 1 while source[index]&.match?(/[ \t]/)
        character = source[index]

        if (closing = QUOTES[character]) && source.index(closing, index + 1)
          return opening_word(source, index + 1, literal: true, depth: depth + 1, base: base, markdown: markdown)
        end

        if markdown && character == '`'
          span = InlineRules.spans(source, links: false, html: false).find do |item|
            item.kind == :code && item.begin_pos == index
          end
          if span
            delimiter = span.delimiter.length
            content_start = index + delimiter
            content_end = span.end_pos - delimiter
            content = source[content_start...content_end]
            padding = content[/\A[ \t]*/].to_s.length
            match = WORD.match(content, padding)
            if match && match.begin(0) == padding && match[0].match?(/\p{L}/)
              return opening_match(match, base + content_start, true, true)
            end
          end
        end

        if markdown && character == '[' && source[index - 1] != '!'
          close = InlineRules.balanced_end(source, index, '[', ']')
          if close
            return opening_word(source, index + 1, literal: literal, depth: depth + 1, base: base, markdown: markdown)
          end
        end

        if markdown && ['*', '_'].include?(character)
          delimiter = source[index..][/\A(?:\*{1,3}|_{1,3})/]
          closing = delimiter && source.index(delimiter, index + delimiter.length)
          if closing
            content_start = index + delimiter.length
            inside = source[content_start...closing]
            return opening_word(inside, literal: literal, depth: depth + 1, base: base + content_start,
                                        markdown: markdown)
          end
        end

        match = WORD.match(source, index)
        return unless match && match.begin(0) == index && match[0].match?(/\p{L}/)

        opening_match(match, base, literal, false)
      end

      def opening_match(match, offset, literal, code)
        OpeningWord.new(word: match[0], begin_pos: offset + match.begin(0), end_pos: offset + match.end(0),
                        literal: literal, code: code)
      end

      def lowercase_opening?(opening)
        return false unless opening&.word&.match?(/\A\p{Ll}/)
        return false if ignored_word?(opening.word)

        !cop_config['PreserveMixedCase'] || !opening.word.match?(/\A\p{Ll}[\p{L}\p{M}\p{N}_]*[\p{Lu}\p{Lt}]/)
      end

      def ambiguous_identifier_opening?(source, opening)
        opening.word.include?('_') ||
          source[opening.end_pos..].match?(%r{\A(?:[.:/@=][\p{L}\p{N}]|://)})
      end

      def identifier_source?(source)
        source.match?(%r{
          https?://
          | www\.
          | [\p{L}\p{N}_]+_[\p{L}\p{N}_]+
          | [\p{L}\p{N}_]+/[\p{L}\p{N}_]+
          | \b[\p{L}\p{N}_]+\.[A-Za-z0-9]{2,}\b
        }ix)
      end

      def validate_config
        styles = cop_config['SupportedStyles']
        unless styles.include?(cop_config['Style'])
          raise RuboCop::ValidationError, "#{cop_name}: Style must be one of #{styles.join(', ')}."
        end

        options = %w[IgnoredWords]
        options << 'MinorWords' if cop_config.key?('MinorWords')
        options.each do |option|
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
