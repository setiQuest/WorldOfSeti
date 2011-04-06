require 'spec_helper'
require 'pathy'

describe Display1Controller do
  before :all do
    Object.pathy!
  end
  
  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'activity'" do
    it "should be successful" do
      get 'activity', :format => :json
      response.should be_success
    end

    it "should follow the JSON spec by having all keys and fields within valid range" do
      get 'activity', :format => :json
      json = ActiveSupport::JSON.decode(response.body)

      # test for presence of primaryBeamLocation
      json.has_json_path?("primaryBeamLocation").should be_true

      # test that primaryBeamLocation's ra has valid values
      json.at_json_path("primaryBeamLocation").has_json_path?("ra").should be_true
      primaryBeamLocation_ra = json.at_json_path("primaryBeamLocation").at_json_path("ra")
      is_primaryBeamLocation_ra_valid = primaryBeamLocation_ra.is_a?(Float) || primaryBeamLocation_ra.is_a?(Integer)
      is_primaryBeamLocation_ra_valid.should be_true

      # test that primaryBeamLocation's dec has valid values
      json.at_json_path("primaryBeamLocation").has_json_path?("dec").should be_true
      primaryBeamLocation_dec = json.at_json_path("primaryBeamLocation").at_json_path("dec")
      primaryBeamLocation_dec_valid = primaryBeamLocation_dec.is_a?(Float) || primaryBeamLocation_dec.is_a?(Integer)
      primaryBeamLocation_dec_valid.should be_true

      # test for presence of fovBeamLocation
      json.has_json_path?("fovBeamLocation").should be_true

      # test that fovBeamLocation's ra has valid values
      json.at_json_path("fovBeamLocation").has_json_path?("ra").should be_true
      fovBeamLocation_ra = json.at_json_path("fovBeamLocation").at_json_path("ra")
      is_fovBeamLocation_ra_valid = fovBeamLocation_ra.is_a?(Float) || fovBeamLocation_ra.is_a?(Integer)
      is_fovBeamLocation_ra_valid.should be_true

      # test that fovBeamLocation's dec has valid values
      json.at_json_path("fovBeamLocation").has_json_path?("dec").should be_true
      fovBeamLocation_dec = json.at_json_path("fovBeamLocation").at_json_path("dec")
      is_fovBeamLocation_dec_valid = fovBeamLocation_dec.is_a?(Float) || fovBeamLocation_dec.is_a?(Integer)
      is_fovBeamLocation_dec_valid.should be_true

      # test for presence of id
      json.has_json_path?("id").should be_true
      json.at_json_path("id").is_a?(Integer).should be_true

      # test for presence of status
      json.has_json_path?("status").should be_true
      json.at_json_path("status").is_a?(String).should be_true
      
    end
  end

end
