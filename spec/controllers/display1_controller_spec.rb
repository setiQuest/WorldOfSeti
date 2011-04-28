################################################################################
#
# File:    display1_controller_spec.rb
# Project: World of SETI (WOS)
# Authors:
#                  Alan Mak
#                  Anthony Tang
#                  Dia Kharrat
#                  Paul Wong
#
# The initial source was worked on by students of Carnegie Mellon Silicon Valley
#
# Copyright 2011 The SETI Institute
#
# World of SETI is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# World of SETI is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with World of SETI.  If not, see<http://www.gnu.org/licenses/>.
#
# Implementers of this code are requested to include the caption
# "Licensed through SETI" with a link to setiQuest.org.
#
# For alternate licensing arrangements, please contact
# The SETI Institute at www.seti.org or setiquest.org.
#
################################################################################
require 'spec_helper'
require 'pathy'
require 'fixtures'
require 'application_controller'

describe Display1Controller do
  before :all do
    # give all ruby objects the pathy gem methods which are used to help parse JSON easier
    Object.pathy!

    # define constants
    @HTTP_500 = "500"
  end
  
  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'activity'" do
    it "should get data successful" do
      sample_activity = TestFixtures::get_json_activity(1, 1, 1000.0, 0, 0, "ON1")
      controller.stub(:get_json_activity).and_return(sample_activity)

      get 'activity', :format => :json
      json = ActiveSupport::JSON.decode(response.body)

      response.should be_success

      # primaryBeam_ra, primaryBeam_dec, fovBeam_ra, fovBeam_dec, id, status
      primaryBeamLocation = json.at_json_path("primaryBeamLocation")
      primaryBeamLocation.at_json_path("ra").should == sample_activity[:primaryBeamLocation]["ra"]
      primaryBeamLocation.at_json_path("dec").should == sample_activity[:primaryBeamLocation]["dec"]
      fovBeamLocation = json.at_json_path("fovBeamLocation")
      fovBeamLocation.at_json_path("ra").should == sample_activity[:fovBeamLocation]["ra"]
      fovBeamLocation.at_json_path("dec").should == sample_activity[:fovBeamLocation]["dec"]

      json.at_json_path("id").should == sample_activity[:id]
      json.at_json_path("status").should == sample_activity[:status]
    end

    it "should follow the JSON spec by having all keys and fields within valid range" do
      sample_activity = TestFixtures::get_json_activity(1, 1, 1000.0, 0, 0, "ON1")
      controller.stub(:get_json_activity).and_return(sample_activity)

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
      controller.stub(:get_json_activity).and_return(TestFixtures::get_json_activity(ApplicationController::MAX_RA+1, ApplicationController::MAX_DEC+1, ApplicationController::MAX_RA+1, ApplicationController::MAX_DEC+1, 0, "Observing"))

      get :activity, :format => :json
      response.should be_success
      
      json = ActiveSupport::JSON.decode(response.body)

      primaryBeamLocation = json.at_json_path("primaryBeamLocation")
      primaryBeamLocation.at_json_path("ra").should == ApplicationController::MAX_RA
      primaryBeamLocation.at_json_path("dec").should == ApplicationController::MAX_DEC

      fovBeamLocation = json.at_json_path("primaryBeamLocation")
      fovBeamLocation.at_json_path("ra").should == ApplicationController::MAX_RA
      fovBeamLocation.at_json_path("dec").should == ApplicationController::MAX_DEC
    end

    it "should set the primaryBeamLocation's and fovBeamLocation's RA and DEC to the valid min value if the value is less than the min" do
      controller.stub(:get_json_activity).and_return(TestFixtures::get_json_activity(ApplicationController::MIN_RA-1, ApplicationController::MIN_DEC-1, ApplicationController::MIN_RA-1, ApplicationController::MIN_DEC-1, 0, "Observing"))

      get :activity, :format => :json
      response.should be_success

      json = ActiveSupport::JSON.decode(response.body)

      primaryBeamLocation = json.at_json_path("primaryBeamLocation")
      primaryBeamLocation.at_json_path("ra").should == ApplicationController::MIN_RA
      primaryBeamLocation.at_json_path("dec").should == ApplicationController::MIN_DEC

      fovBeamLocation = json.at_json_path("primaryBeamLocation")
      fovBeamLocation.at_json_path("ra").should == ApplicationController::MIN_RA
      fovBeamLocation.at_json_path("dec").should == ApplicationController::MIN_DEC
    end

    it "should cap the status length to ApplicationController::ACTIVITY_STATUS_MAX_LENGTH if it is greater than ApplicationController::ACTIVITY_STATUS_MAX_LENGTH" do
      status = "a" * (ApplicationController::ACTIVITY_STATUS_MAX_LENGTH + 1)
      controller.stub(:get_json_activity).and_return(TestFixtures::get_json_activity(0, 0, 0, 0, 0, status))

      get :activity, :format => :json
      response.should be_success

      json = ActiveSupport::JSON.decode(response.body)

      json.at_json_path("status").length.should == ApplicationController::ACTIVITY_STATUS_MAX_LENGTH
    end

    it "should return HTTP status 500 when incorrect data is returned from server" do
      invalid_activity = TestFixtures::get_json_activity(nil, nil, nil, nil, nil, nil)
      controller.stub(:get_json_activity).and_return(invalid_activity)

      get :activity, :format => :json
      
      response.code.should == @HTTP_500
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
      json.at_json_path("id").should == sample_beam[:id]
      json.at_json_path("targetId").should == sample_beam[:targetId]
      json.at_json_path("freq").should == sample_beam[:freq]
      json.at_json_path("ra").should == sample_beam[:ra]
      json.at_json_path("dec").should == sample_beam[:dec]
      json.at_json_path("status").should == sample_beam[:status]
    end

    it "should set the id to 0 if it is set to < 0" do
      sample_beam = TestFixtures::get_json_beam(-1, 1, 1000.0, 0, 0, "ON1")
      controller.stub(:get_json_beam).and_return(sample_beam)
      
      get 'beam', :id => 1, :format => :json
      response.should be_success

      json = ActiveSupport::JSON.decode(response.body)

      json.at_json_path("id").should == 0
    end

    it "should set the targetId to 0 if it is set to < 0" do
      sample_beam = TestFixtures::get_json_beam(1, -1, 1000.0, 0, 0, "ON1")
      controller.stub(:get_json_beam).and_return(sample_beam)
      
      get 'beam', :id => 1, :format => :json

      json = ActiveSupport::JSON.decode(response.body)

      json.at_json_path("targetId").should == 0
    end

    it "should set the freq to 0.0 if it is set to < 0" do
      sample_beam = TestFixtures::get_json_beam(1, 1, -1, 0, 0, "ON1")
      controller.stub(:get_json_beam).and_return(sample_beam)

      get 'beam', :id => 1, :format => :json

      json = ActiveSupport::JSON.decode(response.body)

      json.at_json_path("freq").should == 0.0
    end

    it "should set teh freq to ? if it is null" do
      sample_beam = TestFixtures::get_json_beam(1, 1, nil, 0, 0, "ON1")
      controller.stub(:get_json_beam).and_return(sample_beam)

      get 'beam', :id => 1, :format => :json

      json = ActiveSupport::JSON.decode(response.body)

      json.at_json_path("freq").should == "?"
    end

    it "should set the RA and DEC to the valid min value if the value is less than the min" do
      sample_beam = TestFixtures::get_json_beam(1, 1, 1000.0, ApplicationController::MIN_RA-1, ApplicationController::MIN_DEC-1, "ON1")
      controller.stub(:get_json_beam).and_return(sample_beam)

      get 'beam', :id => 1, :format => :json

      json = ActiveSupport::JSON.decode(response.body)

      json.at_json_path("ra").should == ApplicationController::MIN_RA
      json.at_json_path("dec").should == ApplicationController::MIN_DEC
    end

    it "should set the RA and DEC to the valid max value if the value is greater than the max" do
      sample_beam = TestFixtures::get_json_beam(1, 1, 1000.0, ApplicationController::MAX_RA+1, ApplicationController::MAX_DEC+1, "ON1")
      controller.stub(:get_json_beam).and_return(sample_beam)

      get 'beam', :id => 1, :format => :json

      json = ActiveSupport::JSON.decode(response.body)

      json.at_json_path("ra").should == ApplicationController::MAX_RA
      json.at_json_path("dec").should == ApplicationController::MAX_DEC
    end

    it "should return HTTP status 500 when incorrect data is returned from server" do
      invalid_beam = TestFixtures::get_json_beam(nil, nil, nil, nil, nil, nil)
      controller.stub(:get_json_beam).and_return(invalid_beam)

      get :beam, :format => :json

      response.code.should == @HTTP_500
    end
  end

  describe "waterfall" do
    it "should get data successfully" do
      sample_waterfall = TestFixtures::sample_waterfall
      controller.stub(:get_json_waterfall).and_return(sample_waterfall)

      get :waterfall, :id => 3, :start_row => 5, :format => :json
      json = ActiveSupport::JSON.decode(response.body)

      response.should be_success

      json.at_json_path("id").should == sample_waterfall["id"]
      json.at_json_path("startRow").should == sample_waterfall["startRow"]
      json.at_json_path("endRow").should == sample_waterfall["endRow"]
      json.at_json_path("data").should == sample_waterfall["data"]
    end
  end

  describe "frequency coverage" do
    it "should get data successfully" do
      sample_observation_history = TestFixtures::sample_observation_history
      controller.stub(:get_observational_history_from_server).and_return(sample_observation_history)

      get :frequency_coverage, :id => 23456, :format => :json
      json = ActiveSupport::JSON.decode(response.body)

      response.should be_success
      json.count.should == frequency_num_elements
      0..frequency_num_elements do |i|
        if i == 2 || i == 3 || i == 4
          json[i].should == true
        else
          json[i].should == false
        end
      end
      
    end

    it "should return HTTP status 500 when incorrect data is returned from server" do
      invalid_observation_history = TestFixtures::invalid_observation_history
      controller.stub(:get_observational_history_from_server).and_return(invalid_observation_history)

      get :frequency_coverage, :id => 23456, :format => :json
      
      response.code.should == @HTTP_500
    end
  end

end
