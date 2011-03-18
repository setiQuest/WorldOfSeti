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
    waterfall = get_json_waterfall(params[:id].to_i,params[:start_row].to_i, nil)
    respond_to do |format|
      format.json { render :json => waterfall }
    end
  end

  #
  #
  def baseline_chart
    baseline = get_json_baseline(params[:id])
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
  end

  #
  #
  def activity
    uri = URI.parse("#{SETI_SERVER}/activity")
    response = Net::HTTP.get_response(uri)
    j = ActiveSupport::JSON.decode(response.body)

    respond_to do |format|
      format.json { render :json => j.to_options }
    end
  end

  #
  #
  def beam
    uri = URI.parse("#{SETI_SERVER}/beam?id=#{params[:id]}")
    response = Net::HTTP.get_response(uri)
    j = ActiveSupport::JSON.decode(response.body)

    # the following lines are temporary placeholder until the REST interface
    # is implemented by seti server
    j = {}
    j["name"] = "Polaris"
    j["frequency"] = 1246
    j["status"] = "ON2"
    j["ra"] = 67.82
    j["dec"] = 14.45

    respond_to do |format|
      format.json { render :json => j.to_options }
    end
  end

  #
  #
  def frequency_coverage
    observ_history = get_observational_history(params[:id])[:observationHistory]
    freq_coverage = Array.new(frequency_num_elements){ false }
    observ_history[:freqHistory].each do |item|
      freq_coverage[(item / 100).to_i - 10] = true
    end

    respond_to do |format|
      format.json { render :json => freq_coverage }
    end
  end

  private

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
  def get_json_waterfall(id, start_row, end_row)
    if end_row.nil?
      end_row = start_row + 1
    end
    
    uri = URI.parse("#{SETI_SERVER}/waterfall?id=#{id}&startRow=#{start_row}&endRow=#{end_row}")
    response = Net::HTTP.get_response(uri) 
    j = ActiveSupport::JSON.decode(response.body)
    
    # Convert hash keys to symbols
    return j.to_options
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
  #
  def get_json_baseline(id)
    uri = URI.parse("#{SETI_SERVER}/baseline?id=#{id}")
    response = Net::HTTP.get_response(uri)
    j = ActiveSupport::JSON.decode(response.body)

    j["data"] = Base64::decode64( j["data"] ).unpack("f*")
    j["subChannel"] = rand(baseline_width).to_i;      # subChannel not provided yet from server; we'll use a placeholder for now
    
    # Convert hash keys to symbols
    return j.to_options
  end

  #
  #
  def get_observational_history(id)
    history = {}
    history[:observationHistory]= {}
    history[:observationHistory][:id] = id
    history[:observationHistory][:freqHistory] = 20.times.collect { rand(9000) + 1000 }
    return history
  end
end