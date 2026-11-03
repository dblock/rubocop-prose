# frozen_string_literal: true

RSpec.describe 'Markdown source-mapping integration' do
  before do
    next if ENV['RUBOCOP_MD_PATH']

    skip 'Set RUBOCOP_MD_PATH to a Markdown preprocessor checkout with original-source mapping.'
  end

  IntegrationFixtures.cases('markdown_integration').each do |fixture, data|
    %w[prose_first markdown_first].each do |order|
      context "#{File.basename(fixture)} with #{order} loading" do
        include_examples 'a prose CLI fixture', fixture, data, order
      end
    end
  end
end
