################################################################################
#
# File:    application_controller.rb  
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

class ApplicationController < ActionController::Base
  protect_from_forgery

  include Display1Helper


  # Constants either used in display 1 and/or display 2

  # Location for the SETI Server
  # For access to the data server, please contact Avinesh Agrawal (avinash@seti.org)
  # or Jon Richards (jrichards@seti.org)
#  SETI_SERVER = "Please contact above"
#
  SETI_SERVER = "http://publish.seti.org:8010"

  # Manual test variables
  WOS_MANUAL_TESTS		= false   # change to "true" if doing manual tests

  # Timeout constants for timer updates in milliseconds
  TIMEOUT_ACTIVITY              = 60000
  TIMEOUT_WATERFALL             = 14000
  TIMEOUT_BASELINE              = 60000
  TIMEOUT_BEAM_INFO             = 60000
  TIMEOUT_WEATHER               = 7200000
  TIMEOUT_WEBCAM                = 60000

  # Screen sizes for total width
  SCREENSIZE_WIDTH              = 1920
  SCREENSIZE_HEIGHT             = 1080

  TIMEOUT_RETRY_SHORT           = 60000
  TIMEOUT_RETRY_LONG            = 120000

  # Valid min and max values
  MAX_DEC                       = 90
  MIN_DEC                       = -90
  MAX_RA                        = 24
  MIN_RA                        = 0
  ACTIVITY_STATUS_MAX_LENGTH    = 23 
  ACTIVITY_ID_MAX_VALUE		= 999999999999
  ACTIVITY_ID_MIN_VALUE		= 0

  # Beam status enums
  BEAM_STATUS_ENUMS             = ["ON1", "ON2", "ON3", "OFF1", "OFF2", "OFF3"]
  BEAM_DESCRIPTION_MAX_LENGTH   = 45 
  MAX_FREQ_MHZ			= 10000
  MIN_FREQ_MHZ			= 1000
end
