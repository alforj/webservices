require 'spec_helper'

describe TariffRate::GuatemalaData do
  fixtures_dir = "#{Rails.root}/spec/fixtures/tariff_rates/guatemala"
  fixtures_file = "#{fixtures_dir}/guatemala.csv"
  fixtures_file_bad = "#{fixtures_dir}/guatemala_old.csv"

  s3_good = Aws::S3::Client.new(stub_responses: true, access_key_id: ENV['AWS_ACCESS_KEY_ID_TARIFFS'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY_TARIFFS'])
  s3_good.stub_responses(:get_object, body: open(fixtures_file))

  let(:importer) { described_class.new(fixtures_file, s3_good) }
  let(:expected) { YAML.load_file("#{fixtures_dir}/results.yaml") }

  s3_bad = Aws::S3::Client.new(stub_responses: true, access_key_id: ENV['AWS_ACCESS_KEY_ID_TARIFFS'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY_TARIFFS'])
  s3_bad.stub_responses(:get_object, body: open(fixtures_file_bad))
  let(:importer_bad) { described_class.new(fixtures_file_bad, s3_bad) }

  describe '#import' do
    it 'loads GUATEMALA tariff rates from specified resource' do
      expect(TariffRate::Guatemala).to receive(:index) do |res|
        expect(res).to eq(expected)
      end
      importer.import
    end

    it 'loads incorrectly formatted data and throws an exception' do
      expect { importer_bad.import }.to raise_error
    end

  end

end
