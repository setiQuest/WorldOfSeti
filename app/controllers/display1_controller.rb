require 'base64'

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
    @waterfall1 = {:id => 1,
                  :start_row => 1,
                  :end_row => 100,
                  :data => get_random_waterfall_data
                 }

    @waterfall2 = {:id => 2,
                  :start_row => 1,
                  :end_row => 100,
                  :data => get_random_waterfall_data
                 }

    @waterfall3 = {:id => 3,
                  :start_row => 1,
                  :end_row => 100,
                  :data => get_random_waterfall_data
                 }
  end

  private

  def get_random_waterfall_data

    data = ''
    100.times do |i|
      data += (0...1000).map{(rand(256)).chr}.join
    end

    return Base64::strict_encode64(data)
  end
end
