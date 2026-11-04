# frozen_string_literal: true

RSpec.describe 'In-process CLI isolation' do
  def cli_state
    [Dir.pwd, $stdout, $stderr, $stdin, RuboCop::ConfigLoader.default_configuration.to_yaml,
     RuboCop::ConfigFinder.project_root]
  end

  it 'keeps discovery and format configuration local across alternating workspaces' do
    original = cli_state
    %w[markdown text markdown].each do |format|
      fixture, data = IntegrationFixtures.cases(format).find { |path, _| File.basename(path) == 'custom_extension' }
      run_fixture(fixture, data, 'config', nil, in_process: true)
      expect(cli_state).to eq(original)
    end
  end

  it 'restores streams, configuration, and working directory when invocation raises' do
    original = cli_state
    allow(RuboCop::CLI).to receive(:new).and_raise(ArgumentError, 'CLI initialization failed')

    Dir.mktmpdir('cli-isolation-') do |directory|
      expect { run_fixture_cli([], directory) }.to raise_error(ArgumentError, 'CLI initialization failed')
    end
    expect(cli_state).to eq(original)
  end
end
