class DebugLogController < ApplicationController
  NUMBER_TO_COLOR_MAP = {0=>'0;37', 1=>'32', 2=>'33', 3=>'31', 4=>'31', 5=>'37'}
  
  def index
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
