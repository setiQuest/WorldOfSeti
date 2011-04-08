################################################################################
#
# File:    display1_controller.rb
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
require 'base64'
require "net/http"
require "uri"

class Display1Controller < ApplicationController

  #
  #
  def index
    @baseline1 = get_random_json_baseline
  end

  #
  #
  def waterfall
    waterfall = get_json_waterfall(params[:id].to_i,params[:start_row].to_i)
    respond_to do |format|
      if waterfall.nil?
        logger.error("ERROR: Waterfall object not valid, discarding object.")
        # Respond with error, don't pass JSON, it's bad
        format.json { render :status => 500, :json => {:status => :error, :success => false, :error => true} }
      else
        format.json { render :json => waterfall }
      end
    end
  end

  #
  # Generate the baseline chart using the Google Maps API
  def baseline_chart
    # get the baseline data from the seti web service
    baseline = get_json_baseline(params[:id])
    if baseline    
      chart_data = baseline[:data].join(',')
      marker_index = baseline[:subChannel]

      chart_params = {
        :cht => 'lc',
        :chs => '768x150',
        :chds => '0,20000',
        :chls => '3',							# Line thickness
        :chf => 'bg,s,DDDDDD|c,s,FFFFFF',                                 # Color background
        :chma => '1,1,10,1',
        :chg => '5,20,1,0',                                               # Grid lines
        :chxt => 'x,x,y,y',                                               # Show Axis for X and Y
        :chxr => '0,0,7.68,.5|2,0,2,0.5',                                 # Custom range for X axis | Y axis
        :chxl => '1:|sub-channel number|x10^2|3:|power|x10^4',
        :chxs => '0,000000|1,000000|2,000000|3,000000',                   # Color axis labels to black
        :chxtc => '0,10|2,10',                                            # Tick marks for the labels
        :chem => "y;s=map_pin_icon;d=camping,FFFF00;dp=#{marker_index}",  # We are currently observing
        :chd => "t:#{chart_data}"                                         # Values
      }

      uri = URI.parse("http://chart.googleapis.com/chart")
      response = Net::HTTP.post_form(uri, chart_params)
      send_data response.body, :filename => "baseline-#{params[:id]}_chart.png", :type => 'image/png', :disposition => 'inline'
    else
      logger.error("ERROR: Baseline object not valid, discarding object.")
    end
  end

  #
  # Obtains the activity data from the SETI server and returns it to the client
  # as JSON. If there was an error in the data, it will log an error and return
  # a HTTP 500 status to the client.
  def activity
    j = get_activity_data

    respond_to do |format|
      if j.nil? 
        logger.error("ERROR: Activity object not valid, discarding object.")
        # Respond with error, don't pass JSON, it's bad
        format.json { render :status => 500, :json => {:status => :error, :success => false, :error => true} }
      else
        format.json { render :json => j }
      end
    end
  end

  #
  #
  def beam
    beam = get_json_beam(params[:id])
    
    respond_to do |format|
      if beam.nil?
        logger.error("ERROR: Beam object not valid, discarding object.")
        # Respond with error, don't pass JSON, it's bad
        format.json { render :status => 500, :json => {:status => :error, :success => false, :error => true} }
      else
        format.json { render :json => beam }
      end
    end
  end

  #
  #
  def frequency_coverage
    observ_history = get_observational_history(params[:id])[:observationHistory]
    if observ_history
      freq_coverage = Array.new(frequency_num_elements){ false }
      observ_history[:freqHistory].each do |item|
        # Check bounds
        item = item.to_i
        if item >= MAX_FREQ_MHZ 
           item = MAX_FREQ_MHZ - 1
           logger.warn("Received observational frequency > #{MAX_FREQ_MHZ}; Setting it to #{MAX_FREQ_MHZ} by default to prevent errors.")
        end
        if item < MIN_FREQ_MHZ 
           item = MIN_FREQ_MHZ
           logger.warn("Received observational frequency < #{MIN_FREQ_MHZ}; Setting it to #{MIN_FREQ_MHZ} by default to prevent errors.")
        end

        index = (item/100).to_i - 10
        freq_coverage[index] = true
      end
    end

    respond_to do |format|
      if observ_history.nil?
        logger.error("ERROR: Observational history object not valid, discarding object.")
        # Respond with error, don't pass JSON, it's bad
        format.json { render :status => 500, :json => {:status => :error, :success => false, :error => true} }
      else
        format.json { render :json => freq_coverage }
      end
    end
  end

  protected

  def get_activity_data
    # Do we have a format error (such as nil objects in JSON)
    format_error = false

    uri = URI.parse("#{SETI_SERVER}/activity")
    response = Net::HTTP.get_response(uri)
    j = ActiveSupport::JSON.decode(response.body).to_options

    # Check JSON format
    if j[:primaryBeamLocation].nil? || j[:primaryBeamLocation]["ra"].nil? || j[:primaryBeamLocation]["dec"].nil? \
        || j[:fovBeamLocation].nil? || j[:fovBeamLocation]["ra"].nil? || j[:fovBeamLocation]["dec"].nil? \
        || j[:id].nil? || j[:status].nil?
      format_error = true;
    else
      # Do bounds checking on RA and DEC.
      if j[:primaryBeamLocation]["ra"].to_f > MAX_RA
        logger.warn("Received activity primaryBeamLocation.ra = #{j[:primaryBeamLocation]["ra"]} greater than MAX_RA; reseting it to #{MAX_RA}.")
        j[:primaryBeamLocation]["ra"] = MAX_RA
      end
      if j[:primaryBeamLocation]["ra"].to_f < MIN_RA
        logger.warn("Received activity primaryBeamLocation.ra = #{j[:primaryBeamLocation]["ra"]} less than MIN_RA; reseting it to #{MIN_RA}.")
        j[:primaryBeamLocation]["ra"] = MIN_RA
      end

      if j[:primaryBeamLocation]["dec"].to_f > MAX_DEC
        logger.warn("Received activity primaryBeamLocation.dec = #{j[:primaryBeamLocation]["dec"]} greater than MAX_DEC; reseting it to #{MAX_DEC}.")
        j[:primaryBeamLocation]["dec"] = MAX_DEC
      end
      if j[:primaryBeamLocation]["dec"].to_f < MIN_DEC
        logger.warn("Received activity primaryBeamLocation.dec = #{j[:primaryBeamLocation]["dec"]} less than MIN_DEC; reseting it to #{MIN_DEC}.")
        j[:primaryBeamLocation]["dec"] = MIN_DEC
      end

      # Force activity ID to be an integer
      j[:id] = j[:id].to_i

      # Cap "status" to be less than 80 characters.
      if j[:status].length > ACTIVITY_STATUS_MAX_LENGTH
        logger.warn("Received activity status with length > ACTIVITY_STATUS_MAX_LENGTH; trimming it to #{ACTIVITY_STATUS_MAX_LENGTH}.")
        j[:status] = j[:status].slice(0,ACTIVITY_STATUS_MAX_LENGTH)
      end

      # If in development mode, set the status to Observing so that the display will function when the real
      # display is not observing
      if Rails.env.development?
        j[:status] = "Observing"
      end

      # If there is an object error, invalidate the whole object
      if format_error
        return nil
      else
        return j
      end
    end
  end

  #
  #
  def get_random_waterfall_data
    data = ''
    waterfall_height.times do |i|
      data += (0...waterfall_width).map{(rand(256)).chr}.join
    end

    return Base64::strict_encode64(data)
  end

  #
  #
  def get_json_waterfall(id, start_row)
    # Do we have a format error (such as nil objects in JSON)
    format_error = false

    uri = URI.parse("#{SETI_SERVER}/waterfall?id=#{id}&startRow=#{start_row}")
    response = Net::HTTP.get_response(uri)
    j = ActiveSupport::JSON.decode(response.body).to_options

    if j[:startRow] < 1
      logger.warn("Received waterfall#{id}.startRow = #{j[:startRow]}; reseting it to 1.")
      j[:startRow] = 1
    end

    if j[:endRow] > waterfall_height
      logger.warn("Received waterfall#{id}.endRow = #{j[:endRow]}; reseting it to #{waterfall_height}.")
      j[:endRow] = waterfall_height
    end
    
    # If there is an object error, invalidate the whole object
    if format_error
      return nil
    else
      return j
    end
  end

  #
  # For testing the baseline display. Generates random data
  def get_random_baseline_data
    data = (0...baseline_width*4).map{(rand(256)).chr}.join
    return Base64::strict_encode64(data)
  end

  #
  # For testing the waterfall display. Generates random waterfall data.
  def get_random_json_baseline
    baseline = {}
    baseline[:id] = 1
    baseline[:data] = Base64::decode64(get_random_baseline_data).unpack("f*").to_json()

    return baseline
  end

  #
  # Sends an http request to the SETI webservice to retrieve the baseline data
  # for the id passed in.
  def get_json_baseline(id)
    # Do we have a format error (such as nil objects in JSON)
    format_error = false

    uri = URI.parse("#{SETI_SERVER}/baseline?id=#{id.to_i}")
    response = Net::HTTP.get_response(uri)

    # Decode the json to an object and convert hash keys to symbols
    j = ActiveSupport::JSON.decode(response.body).to_options

    
    if !j[:data].nil?
      j[:data] = Base64::decode64( j[:data] ).unpack("f*")
    else
      logger.error("Received baseline data = nil;")
      format_error = true
    end

    # sanitize data
    if !j[:id].nil?
      j[:id] = j[:id].to_i
      if j[:id] < 0
        logger.warn("Received baseline id < 0; Setting it to 0 by default to prevent errors.")
        j[:id] = 0
      end
    else
      logger.error("Received baseline id = nil")
      format_error = true
    end

    if !j[:subChannel].nil?
      j[:subChannel] = j[:subChannel].to_i
      if j[:subChannel] < 0
        logger.warn("Received baseline subChannel < 0; Setting it to 0 by default to prevent errors.")
        j[:subChannel] = 0
      end
    else
      logger.error("Received baseline subChannel = nil")
      format_error = true
    end
    
    # If there is an object error, invalidate the whole object
    if format_error
      return nil
    else
      return j
    end
  end

  #
  # Obtains the observation history from the SETI webservice, parses the data
  # and returns it as a map. The map includes the id and also the frequency
  # history, which is an array of doubles.
  def get_observational_history(id)
    # Do we have a format error (such as nil objects in JSON)
    format_error = false

    # make the call to the seti webservice
    uri = URI.parse("#{SETI_SERVER}/observationHistory?id=#{id}")
    response = Net::HTTP.get_response(uri)

    # Decode the json to an object and convert hash keys to symbols
    j = ActiveSupport::JSON.decode(response.body).to_options

    history = {}
    history[:observationHistory]= {}

    # sanitize data
    if !j[:id].nil?
      history[:observationHistory][:id] = j[:id]
      if history[:observationHistory][:id] < 0
        logger.warn("Received observation history id < 0; Setting it to 0 by default to prevent errors.")
        history[:observationHistory][:id] = 0
      end
    else
      logger.error("Received observation history id = nil")
      format_error = true
    end

    if !j[:freqHistory].nil?
      history[:observationHistory][:freqHistory] = j[:freqHistory]
    else
      logger.error("Received frequency history = nil")
      format_error = true
    end

    # If there is an object error, invalidate the whole object
    if format_error
      return nil
    else
      return history
    end
  end

  #
  # For testing the observational history/frequency coverage. Generates random data.
  def get_random_observational_history(id)
    history = {}
    history[:observationHistory]= {}
    history[:observationHistory][:id] = id
    history[:observationHistory][:freqHistory] = 20.times.collect { rand(9000) + 1000 }
    return history
  end

  #
  # Obtains the beam data from the SETI web service, performs data checking
  # including for nil and values in range. Sets default values if the data is
  # invalid. Returns the JSON as a map.
  def get_json_beam(id)
    # Do we have a format error (such as nil objects in JSON)
    format_error = false

    uri = URI.parse("#{SETI_SERVER}/beam?id=#{id}")
    response = Net::HTTP.get_response(uri)

    # Decode the json to an object and convert hash keys to symbols
    j = ActiveSupport::JSON.decode(response.body).to_options

    # sanitize data
    if !j[:id].nil?
      j[:id] = j[:id].to_i
      if j[:id] < 0
        logger.warn("Received beam id < 0; Setting it to 0 by default to prevent errors.")
        j[:id] = 0
      end
    else
      logger.error("Received beam id = nil")
      format_error = true
    end

    if !j[:targetId].nil?
      j[:targetId] = j[:targetId].to_i
      if j[:targetId] < 0
        logger.warn("Received beam targetId < 0; Setting it to 0 by default to prevent errors.")
        j[:targetId] = 0
      end
    else
      logger.error("Received beam targetId = nil")
      format_error = true
    end

    if !j[:freq].nil?
      j[:frequency] = j[:freq].to_f
      if j[:frequency] < MIN_FREQ_MHZ
        logger.warn("Received beam frequency < #{MIN_FREQ_MHZ}; Setting it to #{MIN_FREQ_MHZ} by default to prevent errors.")
        j[:frequency] = MIN_FREQ_MHZ
      end
      if j[:frequency] > MAX_FREQ_MHZ
        logger.warn("Received beam frequency > #{MAX_FREQ_MHZ}; Setting it to #{MAX_FREQ_MHZ} by default to prevent errors.")
        j[:frequency] = MAX_FREQ_MHZ 
      end
    else
      logger.error("Received beam frequency = nil")
      format_error = true
    end

    if !j[:ra].nil?
      j[:ra] = j[:ra].to_f
      if j[:ra] < MIN_RA
        logger.warn("Received beam ra < #{MIN_RA}; Setting it to #{MIN_RA} by default to prevent errors.")
        j[:ra] = MIN_RA
      end
      if j[:ra] > MAX_RA
        logger.warn("Received beam ra > #{MAX_RA}; Setting it to #{MAX_RA} by default to prevent errors.")
        j[:ra] = MAX_RA
      end
    else
      logger.error("Received beam ra = nil")
      format_error = true
    end

    if !j[:dec].nil?
      j[:dec] = j[:dec].to_f
      if j[:dec] < MIN_DEC
        logger.warn("Received beam dec < #{MIN_DEC}; Setting it to #{MIN_DEC} by default to prevent errors.")
        j[:dec] = MIN_DEC
      end
      if j[:dec] > MAX_DEC
        logger.warn("Received beam dec > #{MAX_DEC}; Setting it to #{MAX_DEC} by default to prevent errors.")
        j[:dec] = MAX_DEC
      end
    else
      logger.error("Received beam dec = nil")
      format_error = true
    end

    if !j[:status].nil?
      if !is_valid_beam_status(j[:status])
        logger.error("Received an invalid beam status = #{j[:status]}")
        j[:status] = "?"
      end
    else
      logger.error("Received beam status = nil")
      format_error = true
    end

    # If there is an object error, invalidate the whole object
    if format_error
      return nil
    else
      return j
    end
  end

  # Determines if the passed in status is equal to one of the beam status enums
  def is_valid_beam_status(status)
    BEAM_STATUS_ENUMS.each { |x|
      if status == x
        return true
      end
    }

    return false
  end
end
