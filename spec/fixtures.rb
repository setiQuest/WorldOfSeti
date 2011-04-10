include Display1Helper

module TestFixtures

  def self.sample_waterfall
    data = ''
    10.times do |i|
      data += (0...waterfall_width).map{(rand(256)).chr}.join
    end

    return {:id => 3, :startRow => 5, :endRow => 10, :data => Base64::strict_encode64(data)}
  end
end