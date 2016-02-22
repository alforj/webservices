module SalesforceArticle
  class CaseSolutionData < BaseData
    include ::Importable
    include ::VersionableResource

    def query_string
      @query_string ||= <<-SOQL
        SELECT Id,
               Approval_Date__c,
               Approval_Status__c,
               Article_Expiration_Date__c,
               Content__c,
               FirstPublishedDate,
               LastPublishedDate,
               Subject__c,
               Summary,
               Title,
               UrlName,
               (SELECT Id, DataCategoryName, DataCategoryGroupName FROM DataCategorySelections)
        FROM Case_Solution__kav
        WHERE PublishStatus = 'Online'
        AND Language = 'en_US'
        AND IsLatestVersion=true
        AND IsVisibleInPkb=true
      SOQL
    end
  end
end
