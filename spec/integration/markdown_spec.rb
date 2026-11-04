# frozen_string_literal: true

RSpec.describe 'Markdown integration' do
  IntegrationFixtures.cases('markdown').each do |fixture, data|
    context "with #{File.basename(fixture)}" do
      it_behaves_like 'a prose content fixture', fixture, data
    end
  end
end
