require 'escargot'

ActiveRecord::Base.class_eval do
  include Escargot::ModelExtensions
end

module Escargot
  module Adapter
    module ActiveRecord
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

      def self.from_hits(hits)
        hits.collect do |hit|
          model_class = hit._type.gsub(/-/,'/').classify.constantize
          begin
            model_class.find(hit.id)
          rescue ::ActiveRecord::RecordNotFound
            nil
          end
        end
      end
    end
  end
end

Escargot.adapter = Escargot::Adapter::ActiveRecord