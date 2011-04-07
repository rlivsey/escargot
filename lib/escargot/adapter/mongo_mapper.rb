require 'mongo_mapper'
require 'escargot'

module Escargot
  module Adapter
    module MongoMapper
      def self.valid_model?(model)
        true
      end

      def self.all_with_ids(model, ids)
        model.all(:id => ids)
      end

      def self.all_records(model, opts={})
        query_opts = {}

        if opts[:ids_only]
          query_opts[:fields] = [:_id]
        end

        model.find_each(query_opts) do |record|
          yield record
        end
      end

      def self.from_hits(hits)
        hits.collect do |hit|
          model_class = hit._type.gsub(/-/,'/').classify.constantize
          model_class.find(hit.id)
        end
      end
    end
  end
end

# Install into all documents
MongoMapper::Document.plugin Escargot::ModelExtensions
Escargot.adapter = Escargot::Adapter::MongoMapper