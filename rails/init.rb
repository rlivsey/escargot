require 'escargot'

# TODO - maybe move this to initializers/escargot.rb and leave it to the user to setup
# TODO - could be nice to do Escargot.connect(...) which passes that off to ElasticSearch
# TODO - do we need to consider reconnecting on passenger fork?

unless File.exists?(Rails.root + "/config/elasticsearch.yml")
  Rails.logger.warn "No config/elastic_search.yaml file found, connecting to localhost:9200"
  $elastic_search_client = ElasticSearch.new("localhost:9200")
else
  config = YAML.load_file(Rails.root + "/config/elasticsearch.yml")
  $elastic_search_client = ElasticSearch.new(config["host"] + ":" + config["port"].to_s, :timeout => 20)
end