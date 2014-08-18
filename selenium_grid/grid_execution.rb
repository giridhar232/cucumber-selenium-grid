require 'yaml'
require 'fileutils'
require_relative 'grid_helper'
include Grid_Helper

# Load grid_config.yml file
grid_config = YAML.load_file("#{File.dirname(__FILE__)}/grid_config.yml")

# Make paths for HTML, Rerun, and log files
grid_results_path = "#{grid_config['grid_results_path']}/Grid_Execution/#{Time.now.strftime('%m%d%Y%H%M%S')}"
reports_path = "#{grid_results_path}/HTML_Reports"
first_rerun_path = "#{grid_results_path}/ReRun_Files/First"
log_file_path = "#{grid_results_path}/execution.log"
FileUtils.mkdir_p [reports_path, first_rerun_path]

# Load browsers array
browsers = grid_config['browsers'].split(',').each{|a|a.to_s.strip!}

# Block to figure out which execution type to use; file or tags
execution_array = Array.new
case ARGV[0].to_s.downcase
  when "all_files"
    execution_array = Dir["features/**/*.feature"].each {|file| file.to_s.strip}
    log_helper(log_file_path, "No. of Feature Files:: " + execution_array.size.to_s + "\n")
  when "files_in_dir"
    if !ARGV[1].nil?
      execution_array = Dir["#{ARGV[1]}/*.feature"].each {|file| file.to_s.strip}
      log_helper(log_file_path, "No. of Feature Files:: " + execution_array.size.to_s + "\n")
    else
      execution_helper_msg
    end
  when "file"
    if !ARGV[1].nil?
      execution_array << ARGV[1].to_s
      log_helper(log_file_path, "No. of Feature Files:: " + execution_array.size.to_s + "\n")
    else
      execution_helper_msg
    end
  when "tags"
    grid_config['tags'].split(',').each {|a| execution_array << "--tags @" + a.to_s.strip}
  else
    execution_helper_msg
end

threads_array = Array.new

execution_started_at = Time.now
log_helper(log_file_path, "Initial execution started")

# Block to execute each file or tag individually on each of the browser types
browsers.each do |browser| # iterate for each browser we want to run
  execution_array.each do |file_or_tag| # iterate for each file or tag we want to run
    # Get name for report
    if file_or_tag.include? "tags"
      report_name = file_or_tag.gsub("--tags @","")
    else
      report_name = File.basename(file_or_tag).gsub(".feature","")
    end

    # Formulate full filepath and filename for HTML and ReRun
    html_filename = "#{reports_path}/#{browser}_#{report_name}.html"
    first_rerun_html_filename = "#{reports_path}/#{browser}_#{report_name}_first_rerun.html"
    first_rerun_filename = "#{first_rerun_path}/#{browser}_#{report_name}.txt"

    # Prepare Execution command
    run_cmd = "cucumber #{file_or_tag} PORT=#{grid_config['hub_port_number']} BROWSER=#{browser} -f html -o #{html_filename} -f rerun -o #{first_rerun_filename}"
    first_rerun_cmd = "cucumber @#{first_rerun_filename} PORT=#{grid_config['hub_port_number']} BROWSER=#{browser} -f html -o #{first_rerun_html_filename}"

    # Execution thread
    thread_id = Thread.new do
      system run_cmd
      log_helper(log_file_path, "Execution report available at: " + File.expand_path(html_filename).to_s + "\n")
      if File.size(first_rerun_filename) > 0
        system first_rerun_cmd
        log_helper(log_file_path, "Execution report available at: " + File.expand_path(first_rerun_html_filename).to_s + "\n")
      else
        log_helper(log_file_path, "Nothing to execute from: " + File.expand_path(second_rerun_filename).to_s + "\n")
      end
    end
    threads_array << thread_id
  end
end

until (Time.now - execution_started_at >= grid_config['execution_threshold'].to_i || threads_array.size == 0) do
  log_helper(log_file_path, "Waiting for thread pool to complete OR maximum time reached...\n")
  sleep 60
  threads_array.select! { |thr| thr.alive? }
  log_helper(log_file_path, "Current thread pool size: " + threads_array.size.to_s + "\n")
end

if(threads_array.size > 0)
  log_helper(log_file_path, "Pending threads count: " + threads_array.size.to_s)
end

log_helper(log_file_path, "Total execution time: " + ((Time.now - execution_started_at)/60).to_s + " minutes.")
puts "Total execution time: " + ((Time.now - execution_started_at)/60).to_s + " minutes."