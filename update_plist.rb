require 'xcodeproj'

project_path = 'ElShiekh/ElShiekh.xcodeproj'
project = Xcodeproj::Project.open(project_path)

project.targets.each do |target|
  if target.name == 'ElShiekh'
    target.build_configurations.each do |config|
      config.build_settings['INFOPLIST_KEY_AGORA_APP_ID'] = '$(AGORA_APP_ID)'
    end
  end
end

project.save
puts "Added INFOPLIST_KEY_AGORA_APP_ID to ElShiekh target."
