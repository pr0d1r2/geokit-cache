require 'active_record_geocodable'

module Geokit
  module Cache
    module ActiveRecord

      def acts_as_geokit_cache
        include Geokit::Cache::Model
        extend Geokit::Cache::Model::ClassMethods
        is_geocodable :require => true
      end

      def is_geocodable(options = {})
        super
        if options[:cache]
          define_method(:geocoder) do
            options[:cache].to_s.singularize.camelize.constantize
          end
        end
      end

    end
  end
end

ActiveRecord::Base.extend(Geokit::Cache::ActiveRecord)
