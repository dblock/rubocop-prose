# frozen_string_literal: true

RSpec.describe 'rubocop-md interoperability' do
  before do
    next if ENV['RUBOCOP_MD_PATH']

    skip 'Set RUBOCOP_MD_PATH to a Markdown preprocessor checkout with original-source mapping.'
  end

  IntegrationFixtures.cases('markdown_interoperability').each do |fixture, data|
    %w[prose_first markdown_first].each do |order|
      context "with #{File.basename(fixture)} and #{order} loading" do
        if File.basename(fixture) == 'markdown_ruby'
          it_behaves_like 'a prose CLI fixture', fixture, data, order
        else
          it 'reports and corrects the edge case without changing the stabilized content' do
            run_fixture(fixture, data, 'config', order, comprehensive: false)
          end
        end
      end
    end
  end
end
