require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'active_record_connectionless'

class GeokitCache < ActiveRecord::Base
  acts_as_geokit_cache
  emulate_attribute :complete_address
end

class Example < ActiveRecord::Base
  is_geocodable :cache => :geokit_cache
  attr_accessor :complete_address
end


describe GeokitCache do

  before(:each) do
    @geokit_cache = GeokitCache.new
    @geo = mock(Geokit::GeoLoc)
  end

  describe 'cache!' do
    before(:each) do
      @attributes = {:lat => 47, :lng => 47}
      @geokit_cache.should_receive(:attributes=).with(@attributes)
    end

    it 'should save given attributes when record is new' do
      @geokit_cache.should_receive(:save).and_return(true)
      @geokit_cache.should_receive(:new_record?).and_return(true)
      @geokit_cache.cache!(@attributes)
    end

    it 'should save given attributes when record changed' do
      @geokit_cache.should_receive(:save).and_return(true)
      @geokit_cache.should_receive(:new_record?).and_return(false)
      @geokit_cache.should_receive(:changed?).and_return(true)
      @geokit_cache.cache!(@attributes)
    end

    it 'should not save given attributes when record is new nor changed' do
      @geokit_cache.should_not_receive(:save)
      @geokit_cache.should_receive(:new_record?).and_return(false)
      @geokit_cache.should_receive(:changed?).and_return(false)
      @geokit_cache.cache!(@attributes)
    end
  end

  it 'set_instance_variables_from_geo! should set instance variables located in geo' do
    @geokit_cache.stub!(:geo).and_return(@geo)
    GeokitCache::GEO_ATTRIBUTES.each do |geo_attribute|
      @geo.should_receive(:send).with(geo_attribute).and_return(geo_attribute)
      @geokit_cache.should_receive(:instance_variable_set).with(geo_attribute, geo_attribute)
    end
    @geokit_cache.set_instance_variables_from_geo!
  end

  describe 'update_action!' do
    before(:each) do
      @geokit_cache.stub!(:set_instance_variables_from_geo!)
      @geokit_cache.stub!(:changed? => false)
      @geokit_cache.update_action!
    end

    it 'should set instance variables located in geo' do
      @geokit_cache.should_receive(:set_instance_variables_from_geo!)
      @geokit_cache.update_action!
    end

    it 'should save when record changed' do
      @geokit_cache.should_receive(:changed?).and_return(true)
      @geokit_cache.should_receive(:save).and_return(true)
      @geokit_cache.update_action!
    end

    it 'should not save when record not changed' do
      @geokit_cache.should_receive(:changed?).and_return(false)
      @geokit_cache.should_not_receive(:save)
      @geokit_cache.update_action!
    end
  end

  describe 'needs_update?' do
    it 'should be true when record not from google and geo was successful' do
      @geokit_cache.should_receive(:by_google?).and_return(false)
      @geokit_cache.should_receive(:geocoding_successful?).and_return(true)
      @geokit_cache.needs_update?.should be_true
    end

    it 'should be false when record already from google' do
      @geokit_cache.should_receive(:by_google?).and_return(true)
      @geokit_cache.needs_update?.should be_false
    end

    it 'should be false when record not from google and geo was not successful' do
      @geokit_cache.should_receive(:by_google?).and_return(false)
      @geokit_cache.should_receive(:geocoding_successful?).and_return(false)
      @geokit_cache.needs_update?.should be_false
    end
  end

  describe 'update!' do
    it 'should update when needed' do
      @geokit_cache.should_receive(:needs_update?).and_return(true)
      @geokit_cache.should_receive(:update_action!).and_return(true)
      @geokit_cache.update!.should be_true
    end

    it 'should not update when not needed' do
      @geokit_cache.should_receive(:needs_update?).and_return(false)
      @geokit_cache.should_not_receive(:update_action!)
      @geokit_cache.update!.should be_nil
    end
  end

  it 'update_and_return! should update record and return geoloc' do
    @geokit_cache.should_receive(:update!).and_return(true)
    @geokit_cache.should_receive(:geoloc).and_return(:geoloc)
    @geokit_cache.update_and_return!.should == :geoloc
  end

  it 'fake_geoloc should return geoloc with attributes from record' do
    GeokitCache::GEO_ATTRIBUTES.each do |geo_attribute|
      @geokit_cache.should_receive(:instance_variable_get).with(geo_attribute).and_return(geo_attribute)
      @geo.should_receive(:instance_variable_set).with(geo_attribute, geo_attribute)
    end
    @geokit_cache.should_receive(:success?).and_return(true)
    @geo.should_receive(:success=).with(true)
    Geokit::GeoLoc.should_receive(:new).and_return(@geo)
    @geokit_cache.fake_geoloc.should == @geo
  end

  describe 'successful_geoloc' do
    it 'should return geo when it is successful' do
      @geokit_cache.should_receive(:geocoding_successful?).and_return(true)
      @geokit_cache.should_receive(:geo).and_return(:geo)
      @geokit_cache.successful_geoloc.should == :geo
    end

    it 'should return nil when geo is not successful' do
      @geokit_cache.should_receive(:geocoding_successful?).and_return(false)
      @geokit_cache.successful_geoloc.should be_nil
    end
  end

  describe 'geoloc' do
    it 'should return successful geoloc' do
      @geokit_cache.should_receive(:successful_geoloc).and_return(:successful_geoloc)
      @geokit_cache.geoloc.should == :successful_geoloc
    end

    it 'should return fake geoloc when there was no successful geoloc' do
      @geokit_cache.should_receive(:successful_geoloc).and_return(nil)
      @geokit_cache.should_receive(:fake_geoloc).and_return(:fake_geoloc)
      @geokit_cache.geoloc.should == :fake_geoloc
    end
  end

  describe 'by_google?' do
    it 'should be true when provider is google' do
      @geokit_cache.should_receive(:provider).and_return('google')
      @geokit_cache.by_google?.should be_true
    end

    it 'should be true when provider is not google' do
      @geokit_cache.should_receive(:provider).and_return('yahoo')
      @geokit_cache.by_google?.should be_false
    end
  end

  describe 'changed_to_google?' do
    it 'should be true when geocoded by google and provider have been changed' do
      @geokit_cache.should_receive(:by_google?).and_return(true)
      @geokit_cache.should_receive(:provider_changed?).and_return(true)
      @geokit_cache.changed_to_google?.should be_true
    end

    it 'should be false when geocoded by google but provider have not been changed' do
      @geokit_cache.should_receive(:by_google?).and_return(true)
      @geokit_cache.should_receive(:provider_changed?).and_return(false)
      @geokit_cache.changed_to_google?.should be_false
    end

    it 'should be false when not geocoded by google' do
      @geokit_cache.should_receive(:by_google?).and_return(false)
      @geokit_cache.changed_to_google?.should be_false
    end
  end

  describe 'changed?' do
    before(:each) do
      @geokit_cache.stub!(:lat_changed? => false, :lng_changed? => false, :changed_to_google? => false)
    end

    it 'should be true when lat changed' do
      @geokit_cache.should_receive(:lat_changed?).and_return(true)
      @geokit_cache.changed?.should be_true
    end

    it 'should be true when lng changed' do
      @geokit_cache.should_receive(:lng_changed?).and_return(true)
      @geokit_cache.changed?.should be_true
    end

    it 'should be true when changed to google' do
      @geokit_cache.should_receive(:changed_to_google?).and_return(true)
      @geokit_cache.changed?.should be_true
    end

    it 'should be false when none of requested changes occurs' do
      @geokit_cache.changed?.should be_false
    end
  end

  describe 'decode_html_entities_in_text_attributes' do
    it 'should decode html-entities in all text attributes when geocoding was successful' do
      @geokit_cache.should_receive(:geocoding_successful?).and_return(true)
      GeokitCache::TEXT_ATTRIBUTES.each do |text_attribute|
        @geokit_cache.should_receive(:send).with(text_attribute).and_return(text_attribute)
        @geokit_cache.should_receive(:send).with("#{text_attribute}=", text_attribute.to_s)
      end
      @geokit_cache.decode_html_entities_in_text_attributes
    end

    it 'should not decode html-entities in any text attributes when geocoding was not successful' do
      @geokit_cache.should_receive(:geocoding_successful?).and_return(false)
      GeokitCache::TEXT_ATTRIBUTES.each do |text_attribute|
        @geokit_cache.should_not_receive(:send).with(text_attribute)
        @geokit_cache.should_not_receive(:send).with("#{text_attribute}=", text_attribute.to_s)
      end
      @geokit_cache.decode_html_entities_in_text_attributes
    end
  end

  it 'make_complete_address_prepared should use class prepare_complete_address' do
    @geokit_cache.complete_address = 'Complete Address'
    GeokitCache.should_receive(:prepare_complete_address).with('Complete Address').and_return('complete address')
    @geokit_cache.make_complete_address_prepared.should == 'complete address'
  end

  describe 'class method' do
    it 'geocode should return geoloc for updated or new record' do
      record = mock(GeokitCache)
      record.should_receive(:update_and_return!)
      GeokitCache.should_receive(:find_or_create).with(:complete_address).and_return(record)
      GeokitCache.geocode(:complete_address)
    end

    describe 'find_or_create_by_complete_address' do
      it 'should return existing record' do
        GeokitCache.should_receive(:find_by_complete_address).with('complete_address').and_return(:record)
        GeokitCache.find_or_create_by_complete_address('Complete_Address').should == :record
      end

      it 'should create new record when record does not exist in database' do
        GeokitCache.should_receive(:find_by_complete_address).with('complete_address')
        GeokitCache.should_receive(:new).with(:complete_address => 'complete_address').and_return(:new_record)
        GeokitCache.find_or_create_by_complete_address('Complete_Address').should == :new_record
      end
    end

    describe 'prepare_complete_address' do
      it 'should make complete_address downcase' do
        GeokitCache.prepare_complete_address('Complete Address').should == 'complete address'
      end

      it 'should strip leading and trailing spaces' do
        GeokitCache.prepare_complete_address("\n\t complete address \n\t").should  == 'complete address'
      end

      it 'should properly strip colons' do
        GeokitCache.prepare_complete_address('complete,   address,country').should == 'complete, address, country'
        GeokitCache.prepare_complete_address('complete,,   address,,country').should == 'complete, address, country'
        GeokitCache.prepare_complete_address('complete, ,   address, ,country').should == 'complete, address, country'
        GeokitCache.prepare_complete_address("complete, \t,   address, \t,country").should == 'complete, address, country'
      end
    end
  end

end


describe Example do

  it 'geocoder should be GeokitCache' do
    Example.new.geocoder.should == GeokitCache
  end

end
