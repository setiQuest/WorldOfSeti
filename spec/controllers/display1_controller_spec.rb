require 'spec_helper'
require 'pathy'
require 'fixtures'

describe Display1Controller do
  before :all do
    # give all ruby objects the pathy gem methods
    Object.pathy!

    # Define constants
    @MAX_DEC                       = 90
    @MIN_DEC                       = -90
    @MAX_RA                        = 24
    @MIN_RA                        = 0
    @MAX_ACTIVITY_STATUS_LENGTH    = 80
  end
  
  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'activity'" do
    it "should get data successful" do
      sample_activity = TestFixtures::get_activity_data(1, 1, 1000.0, 0, 0, "ON1")
      controller.stub(:get_json_beam).and_return(sample_activity)

      get 'activity', :format => :json
      json = ActiveSupport::JSON.decode(response.body)

      response.should be_success

      # primaryBeam_ra, primaryBeam_dec, fovBeam_ra, fovBeam_dec, id, status
      primaryBeamLocation = json.at_json_path("primaryBeamLocation")
      primaryBeamLocation.at_json_path("ra").should equal sample_activity[:primaryBeamLocation][:ra]
      primaryBeamLocation.at_json_path("dec").should equal sample_activity[:primaryBeamLocation][:dec]
      fovBeamLocation = json.at_json_path("fovBeamLocation")
      fovBeamLocation.at_json_path("ra").should equal sample_activity[:fovBeamLocation][:ra]
      fovBeamLocation.at_json_path("dec").should equal sample_activity[:fovBeamLocation][:dec]

      json.at_json_path("id").should equal sample_activity[:id]
      json.at_json_path("status").should equal sample_activity[:status]
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
      is_primaryBeamLocation_dec_valid = primaryBeamLocation_dec.is_a?(Float) || primaryBeamLocation_dec.is_a?(Integer)
      is_primaryBeamLocation_dec_valid.should be_true

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

    it "should set the primaryBeamLocation's and fovBeamLocation's RA and DEC to the valid max value if the value is greater than the max" do
      controller.stub(:get_activity_data).and_return(TestFixtures::get_activity_data(@MAX_RA+1, @MAX_DEC+1, @MAX_RA+1, @MAX_DEC+1, 0, "Observing"))

      get :activity, :format => :json
      response.should be_success
      
      json = ActiveSupport::JSON.decode(response.body)

      primaryBeamLocation = json.at_json_path("primaryBeamLocation")
      primaryBeamLocation.at_json_path("ra").should equal @MAX_RA
      primaryBeamLocation.at_json_path("dec").should equal @MAX_DEC

      fovBeamLocation = json.at_json_path("primaryBeamLocation")
      fovBeamLocation.at_json_path("ra").should equal @MAX_RA
      fovBeamLocation.at_json_path("dec").should equal @MAX_DEC
    end

    it "should set the primaryBeamLocation's and fovBeamLocation's RA and DEC to the valid min value if the value is less than the min" do
      controller.stub(:get_activity_data).and_return(TestFixtures::get_activity_data(@MIN_RA-1, @MIN_DEC-1, @MIN_RA-1, @MIN_DEC-1, 0, "Observing"))

      get :activity, :format => :json
      response.should be_success

      json = ActiveSupport::JSON.decode(response.body)

      primaryBeamLocation = json.at_json_path("primaryBeamLocation")
      primaryBeamLocation.at_json_path("ra").should equal @MIN_RA
      primaryBeamLocation.at_json_path("dec").should equal @MIN_DEC

      fovBeamLocation = json.at_json_path("primaryBeamLocation")
      fovBeamLocation.at_json_path("ra").should equal @MIN_RA
      fovBeamLocation.at_json_path("dec").should equal @MIN_DEC
    end

    it "should cap the status length to @MAX_ACTIVITY_STATUS_LENGTH if it is greater than @MAX_ACTIVITY_STATUS_LENGTH" do
      controller.stub(:get_activity_data).and_return(TestFixtures::get_activity_data(0, 0, 0, 0, 0, "a" * (@MAX_ACTIVITY_STATUS_LENGTH+1)))

      get :activity, :format => :json
      response.should be_success

      json = ActiveSupport::JSON.decode(response.body)

      json.at_json_path("status").length.should equal @MAX_ACTIVITY_STATUS_LENGTH
    end
  end

  describe "beam" do
    it "should get data successful" do
      sample_beam = TestFixtures::get_json_beam(1, 1, 1000.0, 0, 0, "ON1")
      controller.stub(:get_json_beam).and_return(sample_beam)

      get 'beam', :id => 1, :format => :json
      response.should be_success
            
      json = ActiveSupport::JSON.decode(response.body)
      
      # id, targetId, freq, ra, dec, status
      json.at_json_path("id").should equal sample_beam[:id]
      json.at_json_path("targetId").should equal sample_beam[:targetId]
      json.at_json_path("freq").should equal sample_beam[:freq]
      json.at_json_path("ra").should equal sample_beam[:ra]
      json.at_json_path("dec").should equal sample_beam[:dec]
      json.at_json_path("status").should equal sample_beam[:status]
    end

    it "should set the id to 0 if it is set to < 0" do
      get 'beam', :id => -1, :format => :json
      response.should be_success

      json = ActiveSupport::JSON.decode(response.body)

      json.at_json_path("id").should equal 0
    end

    it "should set the targetId to 0 if it is set to < 0" do
      sample_beam = TestFixtures::get_json_beam(1, -1, 1000.0, 0, 0, "ON1")
      controller.stub(:get_json_beam).and_return(sample_beam)
      
      get 'beam', :id => 1, :format => :json

      json = ActiveSupport::JSON.decode(response.body)

      json.at_json_path("targetId").should equal 0
    end

    it "should set the freq to 0.0 if it is set to < 0" do
      sample_beam = TestFixtures::get_json_beam(1, 1, -1, 0, 0, "ON1")
      controller.stub(:get_json_beam).and_return(sample_beam)

      get 'beam', :id => 1, :format => :json

      json = ActiveSupport::JSON.decode(response.body)

      json.at_json_path("frequency").should equal 0.0
    end

    it "should set the RA and DEC to the valid min value if the value is less than the min" do
      sample_beam = TestFixtures::get_json_beam(1, 1, 1000.0, @MIN_RA-1, @MIN_DEC-1, "ON1")
      controller.stub(:get_json_beam).and_return(sample_beam)

      get 'beam', :id => 1, :format => :json

      json = ActiveSupport::JSON.decode(response.body)

      json.at_json_path("ra").should equal @MIN_RA
      json.at_json_path("dec").should equal @MIN_DEC
    end

    it "should set the RA and DEC to the valid max value if the value is greater than the max" do
      sample_beam = TestFixtures::get_json_beam(1, 1, 1000.0, @MAX_RA+1, @MAX_DEC+1, "ON1")
      controller.stub(:get_json_beam).and_return(sample_beam)

      get 'beam', :id => 1, :format => :json

      json = ActiveSupport::JSON.decode(response.body)

      json.at_json_path("ra").should equal @MAX_RA
      json.at_json_path("dec").should equal @MAX_DEC
    end
  end

  describe "waterfall" do
    it "should get data successfully" do
      sample_waterfall = TestFixtures::sample_waterfall
      controller.stub(:get_json_waterfall).and_return(sample_waterfall)

      get :waterfall, :id => 3, :start_row => 5, :format => :json
      json = ActiveSupport::JSON.decode(response.body)

      response.should be_success

      json.at_json_path("id").should == sample_waterfall[:id]
      json.at_json_path("startRow").should == sample_waterfall[:startRow]
      json.at_json_path("endRow").should == sample_waterfall[:endRow]
      json.at_json_path("data").should == sample_waterfall[:data]
    end
  end

end
