require 'spec_helper'

describe Envirotech::SolutionData do
  include_context 'empty Envirotech indices'
  let(:fixtures_file) { "#{Rails.root}/spec/fixtures/envirotech/solutions.json" }
  let(:expected) { YAML.load_file("#{File.dirname(__FILE__)}/solution/solution_articles.yaml") }
  let(:resource) { fixtures_file }
  let(:importer) { described_class.new(fixtures_file) }

  it_behaves_like 'an importer which can purge old documents'
  it_behaves_like 'a versionable resource'
  it_behaves_like 'an importer which indexes the correct documents'
end
