require 'base64'
require "net/http"
require "uri"

class Display1Controller < ApplicationController

#  {
#
#    waterfall:{
#            id: 1,
#            start_row: 63,
#            end_row: 78,
#            data: TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBv=
#        }
#    }
#}
  def index
    @baseline1 = get_random_json_baseline
  end

  def waterfall
    waterfall = get_json_waterfall(params[:id].to_i,params[:start_row].to_i, nil)
    respond_to do |format|
      format.json{render :json => waterfall}
    end

  end


  def baseline_chart

    # TODO: Create a function which takes in marker index and chart data.
#    if marker_index.nil?
      marker_index = 50
#    end

    chart_data = get_json_baseline(params[:id])[:data].join(',')

    chart_params = {
      :cht => 'lc',
      :chs => '768x150',
      :chds => '0,20000',
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

  private

  def get_random_waterfall_data

    data = ''
    waterfall_height.times do |i|
      data += (0...waterfall_width).map{(rand(256)).chr}.join
    end

    return Base64::strict_encode64(data)
  end


  def get_json_waterfall(id, start_row, end_row)

    if end_row.nil?
      end_row = start_row + 1
    end
    
    uri = URI.parse("http://174.129.14.98:8080/waterfall?id=#{id}&start_row=#{start_row}&end_row=#{end_row}")   
    response = Net::HTTP.get_response(uri) 
    j = ActiveSupport::JSON.decode(response.body)
    
    # Merge strings
    j["data"] = j["data"].join

    # Convert hash keys to symbols
    return j.to_options
  end

  def get_random_baseline_data

    data = (0...baseline_width*4).map{(rand(256)).chr}.join

    return Base64::strict_encode64(data)
  end

  def get_random_json_baseline

    baseline = {}
    baseline[:id] = 1
    baseline[:data] = Base64::decode64(get_random_baseline_data).unpack("f*").to_json()

    return baseline
    
  end

  def get_json_baseline(id)
    uri = URI.parse("http://174.129.14.98:8080/baseline?id=#{id}")
    response = Net::HTTP.get_response(uri)
    j = ActiveSupport::JSON.decode(response.body)

    j["data"] = Base64::decode64( j["data"] ).unpack("f*")
    
    # Convert hash keys to symbols
    return j.to_options
  end
  
end
