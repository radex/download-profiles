command :download do |c|
  c.syntax = 'download-profiles'
  c.summary = 'Download provisioning profiles'
  c.description = "By default, downloads and installs all (development, distribution, iOS, Mac) provisioning profiles. Pass appropriate options to constrain."

  c.option '--platform [PLATFORM]', [:ios, :mac, :all], "Platform of profile (ios, mac or all)"
  c.option '--type [TYPE]', [:development, :distribution, :all], "Type of profile (development, distribution or all)"

  c.action do |args, options|
    platform = options.platform ? options.platform.downcase.to_sym : :all
    type = options.type ? options.type.downcase.to_sym : :all
    
    platforms = (platform == :all) ? [:ios, :mac] : [platform]
    types = (type == :all) ? [:development, :distribution] : [type]
    
    profiles = 
      platforms.product(types).flat_map { |platform, type| try{agent.list_profiles(platform, type)} }
      .select { |profile| profile.status == 'Active'}
    
    say_warning "No active #{type} profiles found." and abort if profiles.empty?
    
    profiles.each do |profile|
      if filename = agent.download_profile(profile)
        say_ok "Successfully downloaded: '#{filename}'"
      else
        say_error "Could not download profile: '#{profile.name}'"
      end
    end
  end
end