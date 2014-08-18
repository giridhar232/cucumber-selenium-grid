[WIP]
cucumber-selenium-grid
======================
Library to distribute cucumber tests onto selenium-grid.

Overview:
=========
Cucumber scripts need to be invoked as multiple units, so that each unit could be assigned to an open instance of a matching node of the Selenium Grid.
Cucumber feature files and/or its scenarios could be grouped as multiple smaller units using “tags”.
The Selenium Grid is a cluster of physical/virtual machines, which are logically organized as a hub, and many nodes.
The entire cluster is driven by “selenium stand alone server” jar file.

Grid Setup:
===========
Please refer "http://docs.seleniumhq.org/docs/07_selenium_grid.jsp" & "https://code.google.com/p/selenium/wiki/Grid2" to setup selenium-grid

Example Setup:
==============
To register HUB   => java -jar selenium-server-standalone-2.38.0.jar -role hub -port 4441
To register Nodes => java -jar selenium-server-standalone-2.38.0.jar -role node  -hub http://<hub_ip_address>:4441/grid/register

Optional parameter in Node registration:
=======================================
• -port 4444 (4444 is default)
• -timeout 30 (30 is default) The timeout in seconds before the hub automatically releases a node that hasn't received any requests for more than the specified number of seconds. After this time, the node will be released for another test in the queue. This helps to clear client crashes without manual intervention. To remove the timeout completely, specify -timeout 0 and the hub will never release the node.
Note: This is NOT the WebDriver timeout for all ”wait for WebElement” type of commands.
• -maxSession 5	(5 is default) The maximum number of browsers that can run in parallel on the node. This is different from the maxInstance of supported browsers (Example: For a node that supports Firefox 3.6, Firefox 4.0  and Internet Explorer 8, maxSession=1 will ensure that you never have more than 1 browser running. With maxSession=2 you can have 2 Firefox tests at the same time, or 1 Internet Explorer and 1 Firefox test).
• -browser < params >	If -browser is not set, a node will start with 5 firefox, 1 chrome, and 1 internet explorer instance (assuming it’s on a windows box). This parameter can be set multiple times on the same line to define multiple types of browsers.
Parameters allowed for -browser: browserName={android, chrome, firefox, htmlunit, internet explorer, iphone, opera} version={browser version} firefox_binary={path to executable binary} chrome_binary={path to executable binary} maxInstances={maximum number of browsers of this type} platform={WINDOWS, LINUX, MAC}
• -registerCycle = how often in ms the node will try to register itself again.Allow to restart the hub without having to restart the nodes.

• HUB: Any physical or virtual machine that can communicate with other nodes on the grid.
  Host IP: <IP_Address_of_HUB_machine> e.g. 192.168.0.1
  Port: <HUB_Port> e.g. 4444
  Selenium Standalone Server version: 2.41.0
• Node
  Host IP: <IP_Address_of_Node_machine> e.g. 192.168.0.2
  Selenium Standalone Server version: 2.41.0
• Node
  Host IP: <IP_Address_of_Node_machine> e.g. 192.168.0.3
  Selenium Standalone Server version: 2.41.0

Grid Status:
============
Grid status could be checked at URL: http://<IP_Address_of_HUB_machine>:<HUB_Port>/grid/console

Grid Usage:
===========
Add the below block to env.rb file

if ENV['PORT']
  caps.native_events = false
  Capybara.register_driver driver_name.to_sym do |app|
    Capybara::Selenium::Driver.new(app,
    :browser => :remote,
    :url => "http://#{grid_config['hub_ip_address']}:" + "#{grid_config['hub_port_number']}" + "/wd/hub",
    :desired_capabilities => caps)
  end
end


Please execute scripts from the parent folder of 'features' folder within the project
=====================================================================================
Usage 1: "ruby selenium_grid/grid_execution.rb all_files" will run all available feature files.
========
Usage 2: "ruby selenium_grid/grid_execution.rb files_in_dir <PATH_TO_DIRECTORY>\" will run all available feature files in a directory.
========
Usage 3: "ruby selenium_grid/grid_execution.rb file <PATH_TO_FEATURE FILE>\" will specific feature file.
========
Usage 4: "ruby selenium_grid/grid_execution.rb tags\" will run all tags found in config/grid_config.yml tags.
========

Grid Config Variables:
======================
Within "grid_config.yml" file which is under "config" folder:
• “browsers” key would hold values of all targeted browsers e.g. chrome, firefox, ie.
• “tags” key would hold values of all tags defined within Feature File suite.

How does Grid work?
===================
• grid_execution.rb
  * Parses through “grid_config.yml” file; creates and invokes multiple “cucumber” commands targeted at the Hub.
  * Creates required information to re-execute failed scenarios.
  * Kicks-off multiple (currently an initial execution PLUS two attempts to execute failures) executions.

Logging:
========
• The initial execution's start time, information from rerun arrays, etc. would be logged to a log file.