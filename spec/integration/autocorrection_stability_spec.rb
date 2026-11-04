# frozen_string_literal: true

RSpec.describe 'Default Markdown autocorrection stability' do
  def semantic_tree(node)
    return if node.type == :blank

    value = case node.type
            when :text then node.value.tr("\n", ' ')
            when :entity then node.value.char
            else node.value
            end
    # Soft wraps, blank padding, delimiter styles, and tight-list rendering may change.
    # Keep every content node, its attributes, and semantic block options in order.
    [node.type, value, node.attr, node.options.slice(:level, :alignment, :lang),
     node.children.filter_map { |child| semantic_tree(child) }]
  end

  def markdown_structure(source)
    # Use the dependency's GFM parser independently of the plugin's source-mapping parser.
    document = Kramdown::Document.new(source, input: 'GFM', hard_wrap: false, gfm_quirks: %i[paragraph_end no_auto_typographic])
    semantic_tree(document.root)
  end

  IntegrationFixtures.cases('markdown_stability').each do |fixture, data|
    it "preserves #{File.basename(fixture)} content and structure through a byte-identical fixed point" do
      original = File.read(File.join(fixture, 'input.md'))
      expected = File.read(File.join(fixture, 'expected.md'))
      structure = markdown_structure(expected)
      expect(markdown_structure(original)).to eq(structure)

      workspace = File.expand_path('../../tmp', __dir__)
      FileUtils.mkdir_p(workspace)
      Dir.mktmpdir('autocorrection-stability-', workspace) do |directory|
        file = File.join(directory, 'example.md')
        File.write(file, original)
        configuration = File.join(directory, '.rubocop.yml')
        config = YAML.safe_load_file(File.join(fixture, '.rubocop.yml'))
        config.delete('plugins') if data.fetch('loading') == 'options'
        File.write(configuration, config.to_yaml)
        command = fixture_command(configuration, [], data.fetch('loading'), nil)
        assert_fixture_report(command + ['example.md'], directory, data.fetch('offenses'))

        previous = original
        seen = { original => 0 }
        stabilized = false
        1.upto(5) do |pass|
          assert_fixture_report(command + ['-a', 'example.md'], directory,
                                data.fetch('remaining_offenses'), corrected: true)
          current = File.read(file)
          expect(markdown_structure(current)).to eq(structure), "Markdown semantics changed after CLI pass #{pass}"
          if current == previous
            stabilized = true
            break
          end

          expect(seen).not_to have_key(current), "CLI pass #{pass} repeated pass #{seen[current]} instead of stabilizing"
          seen[current] = pass
          previous = current
        end
        expect(stabilized).to be(true), 'Autocorrection did not reach a fixed point within five CLI passes'
        expect(File.binread(file)).to eq(expected.b)

        assert_fixture_report(command + ['-a', 'example.md'], directory,
                              data.fetch('remaining_offenses'), corrected: true)
        expect(File.binread(file)).to eq(expected.b)
      end
    end
  end
end
