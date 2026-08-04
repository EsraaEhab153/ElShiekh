require 'xcodeproj'

project_path = 'ElShiekh/ElShiekh.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the Secrets.xcconfig file reference
config_ref = project.files.find { |f| f.path == 'Configuration/Secrets.xcconfig' }
unless config_ref
  # Create group if not exists
  config_group = project.main_group.find_subpath(File.join('ElShiekh', 'Configuration'), true)
  config_group.set_source_tree('<group>')
  config_group.set_path('Configuration')
  config_ref = config_group.new_file('Secrets.xcconfig')
end

# Set it as the base configuration for the ElShiekh project and targets
project.build_configurations.each do |config|
  config.base_configuration_reference = config_ref
end

project.targets.each do |target|
  target.build_configurations.each do |config|
    config.base_configuration_reference = config_ref
  end
end

project.save
puts "Successfully linked Secrets.xcconfig to project configurations."
