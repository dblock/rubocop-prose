# frozen_string_literal: true

RSpec.describe 'Markdown integration' do
  IntegrationFixtures.cases('markdown').each do |fixture, data|
    context File.basename(fixture) do
      include_examples 'a prose CLI fixture', fixture, data
    end
  end
end
