command :download do |c|
  c.syntax = 'download-profiles'
  c.summary = 'Downloads all the active Provisioning Profiles'

  c.option '--type [TYPE]', [:development, :distribution], "Type of profile (development or distribution; defaults to development)"

  c.action do |args, options|
    type = (options.type.downcase.to_sym if options.type) || :development
    profiles = try{agent.list_profiles(type)}.select{|profile| profile.status == 'Active'}

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