include Display1Helper

module TestFixtures

  def self.sample_waterfall
    data = ''
    10.times do |i|
      data += (0...waterfall_width).map{(rand(256)).chr}.join
    end

    return {:id => 3, :startRow => 5, :endRow => 10, :data => Base64::strict_encode64(data)}
  end

  # returns sample activity data in JSON format
  def self.get_json_activity(primaryBeam_ra, primaryBeam_dec, fovBeam_ra, fovBeam_dec, id, status)
    activity = { }

    activity[:primaryBeamLocation] = {}
    activity[:primaryBeamLocation][:ra] = primaryBeam_ra
    activity[:primaryBeamLocation][:dec] = primaryBeam_dec

    activity[:fovBeamLocation] = {}
    activity[:fovBeamLocation][:ra] = fovBeam_ra
    activity[:fovBeamLocation][:dec] = fovBeam_dec

    activity[:id] = id
    activity[:status] = status

    return activity
  end

  # returns sample beam data in JSON format
  def self.get_json_beam(id, targetId, freq, ra, dec, status)
    beam = { }

    beam[:id] = id
    beam[:targetId] = targetId
    beam[:freq] = freq
    beam[:ra] = ra
    beam[:dec] = dec
    beam[:status] = status

    return beam
  end
end