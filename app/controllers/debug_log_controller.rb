################################################################################
#
# File:    debug_log_controller.rb
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
class DebugLogController < ApplicationController
  NUMBER_TO_COLOR_MAP = {0=>'0;37', 1=>'32', 2=>'33', 3=>'31', 4=>'31', 5=>'37'}

  # Loads the Rails log file and displays it in the view.
  def index
    # load the log file for the current rails environment
    log_file = "#{Rails.root}/log/#{Rails.env}.log"

    @log_content = ''

    if File.exists?(log_file)
      log_file = File.open(log_file)

      log_file.each do |line|
        @log_content << line
      end
    else
      @log_content = "No log file exists."
    end

    # replace terminal control characters with HTML tags
    @log_content.gsub!("\033[0;37m", "<span class='log-time'>")
    @log_content.gsub!("\033[0m", '</span>')

    @log_content.gsub!("\033[32m", "<span class='log-info'>")
    @log_content.gsub!("\033[31m", "<span class='log-error'>")
    @log_content.gsub!("\033[33m", "<span class='log-warning'>")
  end
end
