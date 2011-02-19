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
    @waterfall1 = get_json_waterfall(1, 1, 100)

    @waterfall2 = get_json_waterfall(2, 1, 100)

    @waterfall3 = get_json_waterfall(3, 1, 100)

    @baseline1 = get_random_json_baseline
  end

  def waterfall
    waterfall = get_json_waterfall(params[:id].to_i,params[:start_row].to_i, nil)
    respond_to do |format|
      format.json{render :json => waterfall}
    end

  end


  def baseline_chart
    params = {
      :cht => 'lc',
      :chs => '600x200',
      :chds => '0,100',
      :chd => 't:1,5,10,25,57'
    }

    uri = URI.parse("http://chart.googleapis.com/chart")

    response = Net::HTTP.post_form(uri, params)
    response.body

    send_data response.body, :filename => 'baseline_chart.jpg', :type => 'image/jpeg', :disposition => 'inline'
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
