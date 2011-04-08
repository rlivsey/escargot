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

      def self.from_hits(hits)
        return [] if hits.empty?

        # if they're all the same type, fetch in one query and then re-order to maintain original ordering
        if hits.collect(&:_type).uniq.size == 1
          ids     = hits.collect{|hit| hit.id.to_s }
          model   = hits.first._type.gsub(/-/,'/').classify.constantize
          results = all_with_ids(model, ids.dup) # need to dup otherwise they get converted to ObjectIDs as side effect of the query!
          index   = results.inject({}){|memo, result| memo[result.id.to_s] = result; memo }
          ids.collect{|id| index[id] }

        else # TODO - we could do this in a batch per type
          hits.collect do |hit|
            model_class = hit._type.gsub(/-/,'/').classify.constantize
            model_class.find(hit.id)
          end
        end
      end
    end
  end
end

# Install into all documents
MongoMapper::Document.plugin Escargot::ModelExtensions
Escargot.adapter = Escargot::Adapter::MongoMapper