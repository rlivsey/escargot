require 'escargot'

ActiveRecord::Base.class_eval do
  include Escargot::ModelExtensions
end

module Escargot
  module Adapter
    module ActiveRecord
      def self.default_index_name(model)
        model.name.underscore.gsub(/\//,'-')
      end

      def self.default_index_type(model)
        model.name.underscore.gsub(/\//,'-')
      end

      def self.valid_model?(model)
        model.table_exists?
      end

      def self.all_with_ids(model, ids)
        model.all(:conditions => {model.primary_key => ids})
      end

      def self.all_records(model, opts={})
        query_opts = {}

        if opts[:ids_only]
          query_opts[:select] = model.primary_key
        end

        model.find_in_batches(query_opts) do |batch|
          batch.each do |record|
            yield record
          end
        end
      end

      def self.from_hits(hits, options={})
        return [] if hits.empty?

        # if they're all the same type, fetch in one query and then re-order to maintain original ordering
        if hits.collect(&:_type).uniq.size == 1
          ids     = hits.inject({}){|memo, hit| memo[hit.id.to_s] = hit; memo }
          model   = hits.first._type.gsub(/-/,'/').classify.constantize
          results = all_with_ids(model, ids.keys)
          index   = results.inject({}){|memo, result| memo[result.send(model.primary_key).to_s] = result; memo }
          ids.collect do |id, hit|
            doc = index[id]
            doc.hit = hit if doc && options[:include_hit]
            doc
          end

        else # TODO - we could do this in a batch per type
          hits.collect do |hit|
            model_class = hit._type.gsub(/-/,'/').classify.constantize
            begin
              doc = model_class.find(hit.id)
              doc.hit = hit if options[:include_hit]
              doc
            rescue ::ActiveRecord::RecordNotFound
              nil
            end
          end
        end
      end
    end
  end
end

Escargot.adapter = Escargot::Adapter::ActiveRecord