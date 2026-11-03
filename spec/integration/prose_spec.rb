# frozen_string_literal: true

RSpec.describe 'RuboCop prose integration' do
  IntegrationFixtures.cases('prose').each do |fixture, data|
    context "with #{File.basename(fixture)}" do
      it_behaves_like 'a prose CLI fixture', fixture, data
    end
  end
end
