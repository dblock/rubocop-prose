# frozen_string_literal: true

RSpec.describe 'RuboCop prose integration' do
  IntegrationFixtures.cases('integration').each do |fixture, data|
    context File.basename(fixture) do
      include_examples 'a prose CLI fixture', fixture, data
    end
  end
end
