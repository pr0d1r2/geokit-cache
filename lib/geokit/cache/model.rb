require 'rubygems'
require 'htmlentities'
require 'active_record_geocodable'

module Geokit
  module Cache
    module Model

      GEO_ATTRIBUTES = [
        :provider,
        :lng,
        :lat,
        :full_address,
        :state,
        :success,
        :accuracy,
        :city,
        :country_code,
        :precision,
        :street_address,
        :zip
      ]
      TEXT_ATTRIBUTES = [:city, :state, :full_address, :street_address]

      def self.included(base)
        base.class_eval do
          before_save :decode_html_entities_in_text_attributes
          before_save :make_complete_address_downcase
          is_geocodable :require => true
          base.extend(ClassMethods)
        end
      end

      def cache!(attributes)
        self.attributes = attributes
        save if new_record? || changed?
      end

      def set_instance_variables_from_geo!
        GEO_ATTRIBUTES.each do |geo_attribute|
          instance_variable_set(geo_attribute, geo.send(geo_attribute))
        end
      end

      def update_action!
        set_instance_variables_from_geo!
        save if changed?
      end

      def needs_update?
        !by_google? && geocoding_successful?
      end

      def update!
        update_action! if needs_update?
      end

      def update_and_return!
        update!
        geoloc
      end

      def fake_geoloc
        geoloc = Geokit::GeoLoc.new
        GEO_ATTRIBUTES.each do |geo_attribute|
          geoloc.instance_variable_set(geo_attribute, instance_variable_get(geo_attribute))
        end
        geoloc.success = success?
        geoloc
      end

      def successful_geoloc
        geo if geocoding_successful?
      end

      def geoloc
        successful_geoloc || fake_geoloc
      end

      def by_google?
        provider == 'google'
      end

      def changed_to_google?
        by_google? && provider_changed?
      end

      def changed?
        lat_changed? || lng_changed? || changed_to_google?
      end

      def decode_html_entities_in_text_attributes
        TEXT_ATTRIBUTES.each {|a| self.send("#{a}=", HTMLEntities.new.decode(self.send(a)))} if geocoding_successful?
      end

      def make_complete_address_downcase
        self.complete_address = complete_address.downcase
      end

      module ClassMethods
        def geocode(complete_address)
          record = find_or_create(complete_address)
          record.update_and_return!
        end

        def find_or_create_by_complete_address(complete_address)
          find_by_complete_address(complete_address.downcase) || new(:complete_address => complete_address.downcase)
        end
      end

    end
  end
end
