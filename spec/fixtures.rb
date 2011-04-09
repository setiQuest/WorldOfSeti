include Display1Helper

module TestFixtures

  def self.sample_waterfall
    data = ''
    10.times do |i|
      data += (0...waterfall_width).map{(rand(256)).chr}.join
    end

    return {"id" => 3, "startRow" => 5, "endRow" => 10, "data" => Base64::strict_encode64(data)}
  end

  def self.get_activity_data(primaryBeam_ra, primaryBeam_dec, fovBeam_ra, fovBeam_dec, id, status)
    activity = { }

    activity[:primaryBeamLocation] = {}
    activity[:primaryBeamLocation]["ra"] = primaryBeam_ra
    activity[:primaryBeamLocation]["dec"] = primaryBeam_dec

    activity[:fovBeamLocation] = {}
    activity[:fovBeamLocation]["ra"] = fovBeam_ra
    activity[:fovBeamLocation]["dec"] = fovBeam_dec

    activity[:id] = id
    activity[:status] = status

    return activity
  end

  def self.sample_observation_history
    return {"freqHistory" => [1300.0, 1600.0, 1700.0], "id" => 23456}
  end

  def self.invalid_observation_history
    return {'foo' => 5, 'bar' => 3}
  end
end