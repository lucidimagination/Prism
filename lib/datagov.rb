require 'lucid_works'
require 'pp'

collection_name = 'hhs-data-gov'
# look for/create collection, using essential.zip template

server = LucidWorks::Server.new("http://localhost:8888")

begin
  collection = server.collection(collection_name)
rescue RestClient::ResourceNotFound
  puts "Collection #{collection_name} not found, creating..."
  collection = server.create_collection(:name=>collection_name, :template => 'essential.zip')

  settings = collection.settings

  # set all unknown fields to be 'string' type; defaults to 'text_en'
  # 'string' is better for this dataset with many of the attributes served best as facet strings
  settings.unknown_type_handling = 'string'
  settings.save

  collection.create_field(:name => 'agency', :field_type => 'string',
                          :indexed => true, :stored => true, :indexing_options => 'document_only',
                          :facet => true, :include_in_results => true, :use_in_find_similar => true)

  puts "Collection #{collection_name} creation complete."
end

pp collection

# TODO: maybe, if an option is set, empty the collection to start with?   collection.empty!


solr = RSolr.connect(:url => "#{server.solr_uri}#{collection_name}")  # collection.rsolr should, but doesn't, work'

# TODO:snag the first line of the CSV file, s/ /_/, s/^URL/id/, s/..../fgdc_compliance (or maybe more generically handle parenthetical pieces of colunns)

puts "Indexing data.gov catalog..."

solr.get 'update/csv', :params => {
    :commit => true,
    :header => true,
    :fieldnames => 'id,title,agency,subagency,category,date_released,date_updated,time_period,frequency,description,data.gov_data_category_type,specialized_data_category_designation,keywords,citation,agency_program_page,agency_data_series_page,unit_of_analysis,granularity,geographic_coverage,collection_mode,data_collection_instrument,data_dictionary/variable_list,applicable_agency_information_quality_guideline_designation,data_quality_certification,privacy_and_confidentiality,technical_documentation,additional_metadata,fgdc_compliance,statistical_methodology,sampling,estimation,weighting,disclosure_avoidance,questionnaire_design,series_breaks,non-response_adjustment,seasonal_adjustment,statistical_characteristics,feeds_access_point,feeds_file_size,xml_access_point,xml_file_size,csv/txt_access_point,csv/txt_file_size,xls_access_point,xls_file_size,kml/kmz_access_point,kml_file_size,esri_access_point,esri_file_size,rdf_access_point,rdf_file_size,map_access_point,data_extraction_access_point,widget_access_point,high_value_dataset,suggested_by_public',
    'f.privacy_and_confidentiality.map' => 'YES:Yes',
    'f.data_quality_certification.map' =>'YES:Yes',
    'stream.file' => '/Users/erikhatcher/dev/lucid/customers/hhs/data_gov_catalog.csv',
    'stream.contentType' => 'text/csv'
}
puts "data.gov catalog indexing complete."

# TODO: Phase 2
#   - pluck out links to data from the catalog, follow link, being data type aware, and index that content
#       - same collection?  or separate collection for each dataset?  or separate collection by "agency"?
#          - gonna need to size test this stuff a bit to see how much data we're talking about (documents, physical data size)
#       - networking/bandwidth/concerns concerns in following links to data?
