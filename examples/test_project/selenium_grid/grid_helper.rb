module Grid_Helper
  def execution_helper_msg
    puts "Please execute scripts from the parent folder of 'features' folder within the project"
    puts "Execution Type Not Found. Please use one of the following:"
    puts "Using \"ruby selenium_grid/grid_execution.rb all_file\" will run all available feature files."
    puts "Using \"ruby selenium_grid/grid_execution.rb files_in_dir <PATH_TO_DIRECTORY>\" will run all available feature files in a directory."
    puts "Using \"ruby selenium_grid/grid_execution.rb file <PATH_TO_FEATURE FILE>\" will specific feature file."
    puts "Using \"ruby selenium_grid/grid_execution.rb tags\" will run all tags found in config/grid_config.yml tags"
  end

  def log_helper(filename, message)
    log_file = File.new(filename, "a+")
    log_file.puts("#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}: " + message)
    log_file.close
  end
end