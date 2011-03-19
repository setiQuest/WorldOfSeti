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
  SETI_SERVER = "http://174.129.14.98:8010"

  # Timeout constants for timer updates in milliseconds
  TIMEOUT_ACTIVITY              = 60000
  TIMEOUT_WATERFALL             = 2000
  TIMEOUT_BASELINE              = 60000
  TIMEOUT_BEAM_INFO             = 60000
  TIMEOUT_WEBCAM                = 60000
end
