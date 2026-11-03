# frozen_string_literal: true

require 'cgi'
require 'uri'

module RuboCop
  module Prose
    # A source-oriented companion to the AST: reference resolution in Kramdown
    # discards duplicate definitions and the spelling and positions of references.
    class LinkRules
      Link = Struct.new(:begin_pos, :end_pos, :label_begin_pos, :label_end_pos, :label, :destination,
                        :style, :reference, :image, keyword_init: true)
      Definition = Struct.new(:begin_pos, :end_pos, :label, :reference, :destination, keyword_init: true)

      attr_reader :document, :links, :definitions, :html_anchors

      def initialize(document)
        @document = document
        @source = document.source
        @text = @source.dup
        @links = []
        @definitions = []
        @html_anchors = []
        exclude_blocks
        exclude_spans
        scan_definitions
        scan_links
      end

      def range(first, last)
        ::Parser::Source::Range.new(document.buffer, first, last)
      end

      def link_range(link)
        range(link.begin_pos, link.end_pos)
      end

      def label_range(link)
        range(link.label_begin_pos, link.label_end_pos)
      end

      def definition_for(link)
        definitions.find { |definition| definition.reference == link.reference } if link.reference
      end

      def destination(link)
        raw = link.reference ? definition_for(link)&.destination : link.destination
        decode(raw) if raw
      end

      def resolved?(link)
        !link.reference || !definition_for(link).nil?
      end

      def normalize(label)
        normalize_text(decode(label).gsub(/\r?\n[ \t]*(?:>[ \t]*)*/, ' '))
      end

      def normalize_text(text)
        text.gsub(/[[:space:]]+/, ' ').strip.downcase(:fold)
      end

      def decode(text)
        CGI.unescapeHTML(text.gsub(/\\([[:punct:]])/, '\1'))
      end

      def display_text(link)
        return link.destination if link.style == 'autolink'

        root = Parser.parse(link.label).first
        self.class.plain_text(root).gsub(/[[:space:]]+/, ' ').strip
      end

      def self.plain_text(node)
        case node.type
        when :text, :codespan then node.value.to_s
        when :entity then node.value.char
        when :img then node.attr['alt'].to_s
        when :br then ' '
        else node.children.map { |child| plain_text(child) }.join
        end
      end

      def bare_urls(schemes)
        text = @text.dup
        links.each do |link|
          mask(text, link.begin_pos, link.end_pos) unless link.style == 'shortcut_reference' && !resolved?(link)
        end
        return [] if schemes.empty?

        pattern = %r{(?<![\p{L}\p{N}_])(?:#{schemes.map { |scheme| Regexp.escape(scheme) }.join('|')})://[^\s<>]+}i
        text.to_enum(:scan, pattern).filter_map do
          match = Regexp.last_match
          url = match[0].sub(/[.,;:!?'"]+\z/, '')
          { ')' => '(', ']' => '[', '}' => '{' }.each do |closing, opening|
            url = url[0...-1] while url.end_with?(closing) && url.count(closing) > url.count(opening)
          end
          [match.begin(0), match.begin(0) + url.length] unless url.empty?
        end
      end

      def reversed_links
        text = @text.dup
        links.each { |link| mask(text, link.begin_pos, link.end_pos) if resolved?(link) }
        results = []
        index = 0
        while index < text.length
          unless text[index] == '(' && !escaped?(index) && (finish = closing(text, index, '(', ')'))
            index += 1
            next
          end
          last = nil
          last = closing(text, finish + 1, '[', ']') if text[finish + 1] == '['
          if last && !text[(index + 1)...finish].strip.empty? &&
             text[(finish + 2)...last].match?(/\A[^\s]+\z/) && !unescaped_brackets?(finish + 2, last)
            results << [index, last + 1]
            index = last + 1
          else
            index += 1
          end
        end
        results
      end

      def anchors(renderer, additional = [])
        used = Set.new
        explicit_ids = explicit_heading_ids
        document.nodes(:header).each do |node|
          explicit = explicit_ids[node.options[:location]]
          if explicit
            used << explicit
            next
          end
          text = self.class.plain_text(node).gsub(/\r\n?|\n|\t/, ' ')
          slug = case renderer
                 when 'kramdown'
                   value = text.sub(/\A[^a-zA-Z]+/, '').gsub(/[^a-zA-Z0-9 -]/, '').tr(' ', '-').downcase
                   value.empty? ? 'section' : value
                 when 'gitlab'
                   text.downcase.gsub(/[^\p{L}\p{M}\p{N}\p{Pc}\s-]/, '').gsub(/\s/, '-').gsub(/-+/, '-')
                 else
                   text.downcase.gsub(/[^\p{L}\p{M}\p{N}\p{Pc} -]/, '').tr(' ', '-')
                 end
          candidate = slug
          suffix = 0
          while used.include?(candidate)
            suffix += 1
            candidate = "#{slug}-#{suffix}"
          end
          used << candidate
        end
        used.merge(html_anchors).merge(additional)
      end

      private

      def explicit_heading_ids
        # GFM eagerly inserts its own auto IDs into node.attr. Parse without
        # those IDs so the selected renderer, not GFM, controls generated slugs.
        source = @source.dup
        if document.front_matter_line?(1)
          source[0, document.front_matter.length] = document.front_matter.gsub(/[^\r\n]/, ' ')
        end
        root = Parser.parse(source, auto_ids: false, hard_wrap: false,
                                    gfm_quirks: %i[paragraph_end no_auto_typographic]).first
        ids = {}
        pending = [root]
        until pending.empty?
          node = pending.shift
          ids[node.options[:location]] = node.attr['id'] if node.type == :header && node.attr['id']
          pending.concat(node.children)
        end
        ids
      end

      def mask(text, first, last)
        text[first...last] = text[first...last].gsub(/[^\r\n]/, ' ')
      end

      def exclude_blocks
        allowed = document.prose_lines.to_set { |_text, number| number }
        document.lines.each_index do |index|
          next if allowed.include?(index + 1)

          line = document.line_range(index + 1)
          mask(@text, line.begin_pos, line.end_pos)
        end
        @raw_html_starts = document.nodes(:html_element).filter_map do |node|
          next unless node.options[:content_model] == :raw && node.options[:location]

          line = document.line_range(node.options[:location])
          match = /<#{Regexp.escape(node.value)}\b/i.match(@text, line.begin_pos)
          match.begin(0) if match && match.begin(0) < line.end_pos
        end.to_set
      end

      def escaped?(index)
        count = 0
        index -= 1
        while index >= 0 && @source[index] == '\\'
          count += 1
          index -= 1
        end
        count.odd?
      end

      def exclude_spans
        index = 0
        while index < @text.length
          destination = nil
          if @text[index] == '(' && @text[index - 1] == ']' && opening_bracket(index - 1)
            destination = inline_destination(index)
            if destination
              index = destination.last
              next
            end
          end
          if @text[index] == ':' && @text[index - 1] == ']' &&
             (first = opening_bracket(index - 1)) && @source[first + 1] != '^'
            line_start = first.zero? ? nil : @text.rindex("\n", first - 1)
            prefix = @text[(line_start ? line_start + 1 : 0)...first]
            destination = definition_destination(index + 1) if prefix.match?(/\A[ \t]*(?:>[ \t]*)*\z/)
            if destination
              index = destination.last
              next
            end
          end
          if @text[index] == '`' && !escaped?(index)
            finish = codespan_end(index)
          elsif @text[index] == '<' && !escaped?(index)
            finish = html_or_autolink_end(index)
          end
          if finish
            mask(@text, index, finish)
            index = finish
          else
            index += 1
          end
          finish = nil
        end
      end

      def codespan_end(index)
        run = @text[index..][/\A`+/]
        cursor = index + run.length
        while (match = /`+/.match(@text, cursor))
          return match.end(0) if match[0].length == run.length

          cursor = match.end(0)
        end
        nil
      end

      def html_or_autolink_end(index)
        rest = @text[index..]
        # Angle-delimited destinations are not autolinks or HTML elements.
        return if @text[0...index].match?(/(?:\]\(|\]:)[ \t\r\n]*\z/)

        if rest.start_with?('<!--')
          finish = @text.index('-->', index + 4)
          return finish ? finish + 3 : @text.length
        end
        if rest.start_with?('<![CDATA[') || rest.start_with?('<?')
          ending = rest.start_with?('<?') ? '?>' : ']]>'
          finish = @text.index(ending, index + 2)
          return finish ? finish + ending.length : @text.length
        end
        declaration = /\A<![A-Z][^>]*>/m.match(rest)
        return index + declaration[0].length if declaration

        if (match = /\A<(?:([a-z][a-z0-9+.-]{1,31}:[^\s<>]*)|([^<>\s@]+@[^<>\s@]+\.[^<>\s@]+))>/i.match(rest))
          @links << Link.new(begin_pos: index, end_pos: index + match[0].length,
                             label_begin_pos: index + 1, label_end_pos: index + match[0].length - 1,
                             label: match[1] || match[2], destination: match[1] || "mailto:#{match[2]}",
                             style: 'autolink', image: false)
          return index + match[0].length
        end
        match = %r{\A</?([a-z][\w:-]*)\b(?:[^"'<>]|"[^"]*"|'[^']*')*>}im.match(rest)
        return unless match

        tag = match[0]
        name = match[1].downcase
        record_html_anchors(tag, name)
        finish = index + tag.length
        void = %w[area base br col embed hr img input link meta param source track wbr].include?(name)
        if tag !~ %r{\A</|/\s*>\z} && !void
          if %w[script style textarea].include?(name)
            ending = %r{</#{Regexp.escape(name)}\s*>}i.match(@text, finish)
            finish = ending ? ending.end(0) : @text.length
          elsif %w[a code pre].include?(name) || @raw_html_starts.include?(index)
            finish = raw_html_end(finish, name)
          end
        end
        finish
      end

      def record_html_anchors(tag, name)
        # Match complete attributes, not id= appearing inside another value.
        attributes = /\s+([a-z_:][\w:.-]*)(?:\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'=<>`]+)))?/i
        tag.scan(attributes) do |attribute, double, single, bare|
          next unless attribute.downcase == 'id' || (attribute.downcase == 'name' && name == 'a')

          value = double || single || bare
          @html_anchors << CGI.unescapeHTML(value) if value
        end
      end

      def raw_html_end(index, name)
        depth = 1
        cursor = index
        tags = %r{<!--.*?(?:-->|\z)|</?([a-z][\w:-]*)\b(?:[^"'<>]|"[^"]*"|'[^']*')*>}im
        while (match = tags.match(@text, cursor))
          tag = match[0]
          cursor = match.end(0)
          next if tag.start_with?('<!--')

          record_html_anchors(tag, match[1].downcase)
          if !tag.start_with?('</') && %w[script style textarea].include?(match[1].downcase)
            ending = %r{</#{Regexp.escape(match[1])}\s*>}i.match(@text, cursor)
            cursor = ending ? ending.end(0) : @text.length
            next
          end
          next unless match[1].casecmp?(name)

          depth += tag.start_with?('</') ? -1 : 1 unless tag.match?(%r{/\s*>\z})
          return cursor if depth.zero?
        end
        @text.length
      end

      def closing(text, index, opening, ending)
        return unless text[index] == opening

        depth = 1
        cursor = index + 1
        while cursor < text.length
          return if text[cursor] == "\n" && text[cursor..].match?(/\A\n[ \t\r]*\n/)

          unless escaped?(cursor)
            depth += 1 if text[cursor] == opening
            depth -= 1 if text[cursor] == ending
            return cursor if depth.zero?
          end
          cursor += 1
        end
        nil
      end

      def opening_bracket(ending)
        return if escaped?(ending)

        depth = 1
        cursor = ending - 1
        while cursor >= 0
          return if @text[cursor] == "\n" && @text[cursor..ending].match?(/\A\n[ \t\r]*\n/)

          unless escaped?(cursor)
            depth += 1 if @text[cursor] == ']'
            depth -= 1 if @text[cursor] == '['
            return cursor if depth.zero?
          end
          cursor -= 1
        end
        nil
      end

      def unescaped_brackets?(first, last)
        (first...last).any? { |index| ['[', ']'].include?(@source[index]) && !escaped?(index) }
      end

      def whitespace(index, text = @text)
        cursor = index
        while text[cursor]&.match?(/[ \t\r\n]/)
          newline = text[cursor] == "\n"
          cursor += 1
          cursor += text[cursor..][/\A[ \t]*(?:>[ \t]*)+/].to_s.length if newline
        end
        return if text[index...cursor].count("\n") > 1

        cursor
      end

      def read_destination(index)
        if @source[index] == '<'
          cursor = index + 1
          while cursor < @source.length
            return [@source[(index + 1)...cursor], cursor + 1] if @source[cursor] == '>' && !escaped?(cursor)
            return if @source[cursor] == "\n" || (@source[cursor] == '<' && !escaped?(cursor))

            cursor += 1
          end
          return
        end
        cursor = index
        depth = 0
        while cursor < @source.length
          char = @source[cursor]
          break if char.match?(/\s/) || (char == ')' && depth.zero? && !escaped?(cursor))

          unless escaped?(cursor)
            return if char == '<'

            depth += 1 if char == '('
            depth -= 1 if char == ')'
          end
          cursor += 1
        end
        [@source[index...cursor], cursor] if depth.zero?
      end

      def title_end(index)
        opening = @source[index]
        return unless ['"', "'", '('].include?(opening)

        ending = opening == '(' ? ')' : opening
        cursor = index + 1
        while cursor < @source.length
          return cursor + 1 if @source[cursor] == ending && !escaped?(cursor)
          return if @source[cursor, 2] == "\n\n"

          cursor += 1
        end
        nil
      end

      def inline_destination(index)
        first = whitespace(index + 1, @source)
        return unless first

        if first > index + 1 && ['"', "'"].include?(@source[first]) && (ending = title_end(first))
          finish = whitespace(ending, @source)
          return ['', finish + 1] if finish && @source[finish] == ')'
        end
        result = read_destination(first)
        return unless result

        value, ending = result
        finish = whitespace(ending, @source)
        return unless finish
        return [value, finish + 1] if @source[finish] == ')'
        return unless finish > ending && (title = title_end(finish))

        finish = whitespace(title, @source)
        [value, finish + 1] if finish && @source[finish] == ')'
      end

      def definition_destination(index)
        start = whitespace(index, @source)
        result = read_destination(start) if start
        return unless result

        value, finish = result
        gap = whitespace(finish, @source)
        title = title_end(gap) if gap && gap > finish
        finish = title if title && @source[title..].match?(/\A[ \t]*(?:\r?\n|\z)/)
        return unless @source[finish..].match?(/\A[ \t]*(?:\r?\n|\z)/)
        return if value.empty? && @source[start] != '<'

        [value, finish]
      end

      def scan_definitions
        offset = 0
        @text.lines.each do |line|
          prefix = line[/\A[ \t]*(?:>[ \t]*)*/].length
          first = offset + prefix
          ending = closing(@text, first, '[', ']')
          if ending && @text[ending + 1] == ':' && !escaped?(first)
            label = @source[(first + 1)...ending]
            result = nil
            if !label.start_with?('^') && !unescaped_brackets?(first + 1, ending) && !normalize(label).empty?
              result = definition_destination(ending + 2)
            end
            if result
              value, finish = result
              @definitions << Definition.new(begin_pos: first, end_pos: finish, label: label,
                                             reference: normalize(label), destination: value)
            end
          end
          offset += line.length
        end
        definitions.each { |definition| mask(@text, definition.begin_pos, definition.end_pos) }
        links.reject! do |link|
          definitions.any? do |definition|
            link.begin_pos.between?(definition.begin_pos, definition.end_pos - 1)
          end
        end
      end

      def scan_links
        cursor = 0
        while cursor < @text.length
          unless @text[cursor] == '[' && !escaped?(cursor)
            cursor += 1
            next
          end
          link = parse_link(cursor)
          unless link
            cursor += 1
            next
          end
          links << link
          # Images may supply the accessible text of an outer link.
          nested = cursor + 1
          while !link.image && nested < link.label_end_pos
            if @text[nested] == '[' && @text[nested - 1] == '!' && !escaped?(nested - 1)
              image = parse_link(nested)
              links << image if image&.image && image.end_pos <= link.label_end_pos
              nested = image.end_pos if image
            end
            nested += 1
          end
          cursor = link.end_pos
        end
        links.reject! do |link|
          link.style == 'autolink' && links.any? do |outer|
            outer.style == 'inline' && link.begin_pos > outer.label_end_pos && link.end_pos <= outer.end_pos
          end
        end
        links.sort_by!(&:begin_pos)
      end

      def parse_link(index)
        ending = closing(@text, index, '[', ']')
        return unless ending

        label = @source[(index + 1)...ending]
        return if label.start_with?('^') || task_marker?(index, label)

        image = index.positive? && @text[index - 1] == '!' && !escaped?(index - 1)
        link = Link.new(begin_pos: image ? index - 1 : index, label_begin_pos: index + 1,
                        label_end_pos: ending, label: label, image: image)
        if @text[ending + 1] == '(' && (result = inline_destination(ending + 1))
          link.destination, link.end_pos = result
          link.style = 'inline'
        else
          following = whitespace(ending + 1)
          last = closing(@text, following, '[', ']') if following && @text[following] == '['
          if last && !unescaped_brackets?(following + 1, last) && @source[following + 1] != '^'
            reference = @source[(following + 1)...last]
            link.style = reference.empty? ? 'collapsed_reference' : 'full_reference'
            link.reference = normalize(reference.empty? ? label : reference)
            link.end_pos = last + 1
          else
            return if unescaped_brackets?(index + 1, ending) || normalize(label).empty?

            link.style = 'shortcut_reference'
            link.reference = normalize(label)
            link.end_pos = ending + 1
          end
        end
        return if !link.image && nested_link?(link)

        link
      end

      def nested_link?(outer)
        return true if links.any? do |link|
          link.style == 'autolink' && link.begin_pos >= outer.label_begin_pos && link.end_pos <= outer.label_end_pos
        end

        cursor = outer.label_begin_pos
        while cursor < outer.label_end_pos
          if @text[cursor] == '[' && !escaped?(cursor)
            inner = parse_link(cursor)
            return true if inner && !inner.image && resolved?(inner) && inner.end_pos <= outer.label_end_pos

            cursor = inner.end_pos - 1 if inner
          end
          cursor += 1
        end
        false
      end

      def task_marker?(index, label)
        return false unless label.match?(/\A[ xX]\z/)

        start = @source.rindex("\n", index - 1) unless index.zero?
        @source[(start ? start + 1 : 0)...index].match?(/\A[ \t>]*(?:[-+*]|\d+[.)])[ \t]+\z/)
      end
    end
  end
end
