require 'spec_helper'

describe TradeEvent::UstdaData do
  let(:resource)     { "#{Rails.root}/spec/fixtures/trade_events/ustda/events.xml" }
  let(:importer)     { TradeEvent::UstdaData.new(resource) }
  let(:expected)     { YAML.load_file("#{File.dirname(__FILE__)}/ustda/expected_ustda_events.yaml") }

  it_behaves_like 'an importer which can purge old documents'
  it_behaves_like 'a versionable resource'
  it_behaves_like 'an importer which indexes the correct documents'

  describe '#cost' do
    it 'processes the cost correctly' do
      entry = { cost: 10, cost_currency: 'USD' }
      expect(importer.send(:cost, entry)).to eq([10.00, 'USD'])
    end
  end
end
