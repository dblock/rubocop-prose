# frozen_string_literal: true

RSpec.describe 'Plain-text integration' do
  IntegrationFixtures.cases('text').each do |fixture, data|
    context File.basename(fixture) do
      include_examples 'a prose CLI fixture', fixture, data
    end
  end
end
