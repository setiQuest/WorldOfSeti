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
    data = ''
    uri = URI.parse("http://174.129.14.98:8080/waterfall?id=#{id}&start_row=#{start_row}&end_row=#{end_row}")   
    response = Net::HTTP.get_response(uri) 
    j = ActiveSupport::JSON.decode(response.body)
    
    # Merge strings
    j["data"] = j["data"].join

    # Convert hash keys to symbols
    return j.to_options
  end

end
