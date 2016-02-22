module SalesforceArticle
  class BaseData
    attr_accessor :client

    FIELD_MAPPING = {
      'Id'                         => :id,
      'Agreement_Description__c'   => :agreement_description,
      'Agreement_Status__c'        => :agreement_status,
      'Agreement_Text__c'          => :agreement_text,
      'Agreement_Type__c'          => :agreement_type,
      'Approval_Date__c'           => :approval_date,
      'Approval_Status__c'         => :approval_status,
      'Approver__c'                => :approver,
      'Article_Expiration_Date__c' => :article_expiration_date,
      'Atom__c'                    => :atom,
      'Business_Unit__c'           => :business_unit,
      'Chapter__c'                 => :chapter,
      'Content__c'                 => :content,
      'Exporter_Guide__c'          => :exporter_guide,
      'FirstPublishedDate'         => :first_published_date,
      'LastPublishedDate'          => :last_published_date,
      'Lead_DMO__c'                => :lead_dmo,
      'Notes__c'                   => :notes,
      'Public_URL__c'              => :public_url,
      'References__c'              => :reference,
      'Section__c'                 => :section,
      'Subject__c'                 => :subject,
      'Summary'                    => :summary,
      'Support_DMO__c'             => :support_dmo,
      'TARA_Document_Title__c'     => :tara_document_title,
      'Title'                      => :title,
      'UrlName'                    => :url_name,
    }

    DATA_CATEGORY_GROUP_NAMES = %w(Geographies Industries Trade_Topics).freeze

    def query_string
      fail 'Must be overridden by subclass'
    end

    def initialize(client = nil)
      @client = client || Restforce.new(Rails.configuration.restforce)

      @taxonomy_parser = TaxonomyParser.new(Rails.configuration.frozen_protege_source)
      @taxonomy_parser.concepts = YAML.load_file(Rails.configuration.frozen_taxonomy_concepts)
    end

    def loaded_resource
      @loaded_resource ||= @client.query(query_string)
    end

    def import
      model_class.index indexable_entries
    end

    def indexable_entries
      loaded_resource.map do |article|
        entry = remap_keys(FIELD_MAPPING, article)
        entry = sanitize_entry(entry)

        process_date_fields(entry)
        extract_taxonomy_fields(entry, article)

        entry[:source] = self.model_class.source[:code]
        entry
      end
    end

    def extract_taxonomy_fields(entry, article)
      taxonomy_terms = extract_taxonomies article['DataCategorySelections']

      entry[:industries] = extract_terms_by_concept_group('Industries', taxonomy_terms)
      entry[:topics] = extract_terms_by_concept_group('Topics', taxonomy_terms)

      process_geo_fields(entry, taxonomy_terms)
    end

    def process_geo_fields(entry, taxonomy_terms)
      entry[:countries] = extract_terms_by_concept_group('Countries', taxonomy_terms)
      entry[:countries] = entry[:countries].map { |country| lookup_country(country) }.compact

      entry.merge! add_geo_fields(entry[:countries])

      entry[:trade_regions].concat(extract_terms_by_concept_group('Trade Regions', taxonomy_terms)).uniq!
      entry[:world_regions].concat(extract_terms_by_concept_group('World Regions', taxonomy_terms)).uniq!
    end

    def process_date_fields(entry)
      entry[:first_published_date] = parse_date(entry[:first_published_date]) if entry[:first_published_date]
      entry[:last_published_date] = parse_date(entry[:last_published_date]) if entry[:last_published_date]
      entry[:article_expiration_date] = parse_date(entry[:article_expiration_date]) if entry[:article_expiration_date]
    end

    def extract_terms_by_concept_group(concept_group, terms)
      terms.select { |term| term[:concept_groups].include?(concept_group) }.map { |term| term[:label] }
    end

    def extract_taxonomies(data_categories)
      filtered_data_categories = filter_data_categories data_categories

      filtered_data_categories.each_with_object([]) do |dc, taxonomies|
        label = dc.DataCategoryName.gsub(/_/, ' ')
        concept = @taxonomy_parser.get_concept_by_label(label)
        taxonomies << concept if concept
      end
    end

    def filter_data_categories(data_categories)
      data_categories ||= []
      data_categories.select do |dc|
        DATA_CATEGORY_GROUP_NAMES.include? dc.DataCategoryGroupName
      end
    end
  end
end
