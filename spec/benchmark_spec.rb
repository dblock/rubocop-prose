# frozen_string_literal: true

RSpec.describe 'Prose benchmarks' do
  it 'benchmarks both formats without overwriting existing files' do
    script = File.expand_path('../benchmark/prose.rb', __dir__)
    Dir.mktmpdir('prose-benchmark') do |directory|
      paths = %w[benchmark.md benchmark.txt].map { |name| File.join(directory, name) }
      paths.each { |path| File.write(path, 'Keep this file unchanged.') }

      stdout, stderr, status = Open3.capture3(
        { 'ITERATIONS' => '1', 'SECTIONS' => '1' }, RbConfig.ruby, script, chdir: directory
      )

      expect(status.success?).to be(true), "#{stdout}\n#{stderr}"
      expect(stdout).to include('correct/markdown', 'correct/text')
      paths.each { |path| expect(File.read(path)).to eq('Keep this file unchanged.') }
    end
  end
end
