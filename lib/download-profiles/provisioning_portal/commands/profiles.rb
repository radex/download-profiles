command :download do |c|
  c.syntax = 'download-profiles'
  c.summary = 'Download provisioning profiles'
  c.description = "By default, downloads and installs all (development, distribution, iOS, Mac) provisioning profiles. Pass appropriate options to constrain."

  c.option '--platform [PLATFORM]', [:ios, :mac, :all], "Platform of profile (ios, mac or all)"
  c.option '--type [TYPE]', [:development, :distribution, :all], "Type of profile (development, distribution or all)"

  c.action do |args, options|
    # parse options
    platform = options.platform ? options.platform.downcase.to_sym : :all
    type = options.type ? options.type.downcase.to_sym : :all
    
    platforms = (platform == :all) ? [:ios, :mac] : [platform]
    types = (type == :all) ? [:development, :distribution] : [type]
    
    # get list of profiles
    profiles = 
      platforms.product(types).flat_map { |platform, type| try{agent.list_profiles(platform, type)} }
      .select { |profile| profile.status == 'Active'}
    
    say_warning "No active #{type} profiles found." and abort if profiles.empty?
    
    # download
    failure = false
    profiles.each do |profile|
      if filename = agent.download_profile(profile)
        say "Downloaded #{filename}"
      else
        say_error "Could not download profile: '#{profile.name}'"
        failure = true
      end
    end
    
    if failure
      say_warning "Not all profiles downloaded successfully"
    else
      say_ok "All profiles downloaded successfully"
    end
  end
end