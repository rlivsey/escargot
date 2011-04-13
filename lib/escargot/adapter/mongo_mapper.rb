require 'mongo_mapper'
require 'escargot'

module Escargot
  module Adapter
    module MongoMapper
      def self.default_index_name(model)
        model.name.underscore.gsub(/\//,'-')
      end

      def self.default_index_type(model)
        model.name.underscore.gsub(/\//,'-')
      end

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

      def self.from_hits(hits, options={})
        return [] if hits.empty?

        # if they're all the same type, fetch in one query and then re-order to maintain original ordering
        if hits.collect(&:_type).uniq.size == 1
          ids     = hits.inject({}){|memo, hit| memo[hit.id.to_s] = hit; memo }
          model   = hits.first._type.gsub(/-/,'/').classify.constantize
          results = all_with_ids(model, ids.keys)
          index   = results.inject({}){|memo, result| memo[result.id.to_s] = result; memo }
          ids.collect do |id, hit|
            doc = index[id]
            doc.hit = hit if doc && options[:include_hit]
            doc
          end

        else # TODO - we could do this in a batch per type
          hits.collect do |hit|
            model_class = hit._type.gsub(/-/,'/').classify.constantize
            doc = model_class.find(hit.id)
            doc.hit = hit if doc && options[:include_hit]
            doc
          end
        end
      end
    end
  end
end

# Install into all documents
MongoMapper::Document.plugin Escargot::ModelExtensions
Escargot.adapter = Escargot::Adapter::MongoMapper