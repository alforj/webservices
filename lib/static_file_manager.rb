require 'aws-sdk-core'

class StaticFileManager
  CREDENTIALS = Aws::Credentials.new(Rails.configuration.aws_credentials[:access_key_id], Rails.configuration.aws_credentials[:secret_access_key])

  def self.upload_all_files(search_class, s3 = nil)
    s3_client = get_s3_client(s3)

    search_data = search_class.fetch_all[:hits]
    %w(csv tsv).each do |format|
      file_data = search_class.send("as_#{format}", search_data)
      s3_client.put_object(bucket: 'search-api-static-files', key: "#{search_class.to_s.underscore}.#{format}", body: file_data)
    end
  end

  def self.download_file(file_name, s3 = nil)
    s3_client = get_s3_client(s3)
    s3_client.get_object(bucket: 'search-api-static-files', key: file_name)
  end

  private

  def self.get_s3_client(s3)
    s3 || Aws::S3::Client.new(region: 'us-east-1', credentials: CREDENTIALS)
  end
end