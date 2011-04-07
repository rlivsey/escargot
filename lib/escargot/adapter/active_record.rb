require 'escargot'

ActiveRecord::Base.class_eval do
  include Escargot::ModelExtensions
end

module Escargot
  module Adapter
    module ActiveRecord
    end
  end
end
