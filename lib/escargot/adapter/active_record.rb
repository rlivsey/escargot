require 'escargot'

ActiveRecord::Base.class_eval do
  include Escargot::ActiveRecordExtensions
end

module Escargot
  module Adapter
    module ActiveRecord
    end
  end
end

