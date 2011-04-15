################################################################################
#
# File:    fixtures.rb
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
include Display1Helper

module TestFixtures

  # Creates and returns a sample waterfall with random data used for display 1
  # controller tests.
  def self.sample_waterfall
    data = ''
    10.times do |i|
      data += (0...waterfall_width).map{(rand(256)).chr}.join
    end

    return {"id" => 3, "startRow" => 5, "endRow" => 10, "data" => Base64::strict_encode64(data)}
  end

  # Returns sample activity data in JSON format using the parameters passed in
  def self.get_json_activity(primaryBeam_ra, primaryBeam_dec, fovBeam_ra, fovBeam_dec, id, status)
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

  # Returns a sample observation history
  def self.sample_observation_history
    return {"freqHistory" => [1300.0, 1600.0, 1700.0], "id" => 23456}
  end

  # Returns an invalid sample observation history
  def self.invalid_observation_history
    return {'foo' => 5, 'bar' => 3}
  end
  
  # Returns sample beam data in JSON format using the parameters passed in
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