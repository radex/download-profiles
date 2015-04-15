require 'mechanize'
require 'security'
require 'uri'
require 'json'
require 'date'
require 'time'
require 'logger'

module Cupertino
  module ProvisioningPortal
    class Agent < ::Mechanize
      attr_accessor :username, :password, :team, :team_id

      def initialize
        super
        @profile_csrf_headers = {}
        self.user_agent_alias = 'Mac Safari'

        self.log ||= Logger.new(STDOUT)
        self.log.level = Logger::ERROR

        if ENV['HTTP_PROXY']
          uri = URI.parse(ENV['HTTP_PROXY'])
          user = ENV['HTTP_PROXY_USER'] if ENV['HTTP_PROXY_USER']
          password = ENV['HTTP_PROXY_PASSWORD'] if ENV['HTTP_PROXY_PASSWORD']

          set_proxy(uri.host, uri.port, user || uri.user, password || uri.password)
        end

        pw = Security::InternetPassword.find(:server => Cupertino::ProvisioningPortal::HOST)
        @username, @password = pw.attributes['acct'], pw.password if pw
      end

      def username=(value)
        @username = value

        pw = Security::InternetPassword.find(:a => self.username, :server => Cupertino::ProvisioningPortal::HOST)
        @password = pw.password if pw
      end

      def get(uri, parameters = [], referer = nil, headers = {})
        uri = ::File.join("https://#{Cupertino::ProvisioningPortal::HOST}", uri) unless /^https?/ === uri

        3.times do
          super(uri, parameters, referer, headers)

          return page unless page.respond_to?(:title)

          case page.title
          when /Sign in with your Apple ID/
            login!
          when /Select Team/
            select_team!
          else
            return page
          end
        end

        raise UnsuccessfulAuthenticationError
      end

      def list_profiles(platform, type)
        url = case type
              when :development
                "https://developer.apple.com/account/#{platform}/profile/profileList.action?type=limited"
              when :distribution
                "https://developer.apple.com/account/#{platform}/profile/profileList.action?type=production"
              else
                raise ArgumentError, 'Provisioning profile type must be :development or :distribution'
              end

        self.pluggable_parser.default = Mechanize::File
        get(url)

        regex = /profileDataURL = "([^"]*)"/
        profile_data_url = (page.body.match regex or raise UnexpectedContentError)[1]

        profile_data_url += case type
                            when :development
                              '&type=limited'
                            when :distribution
                              '&type=production'
                            end
        
        profile_data_url += "&pageSize=50&pageNumber=1&sort=name=asc"
        
        post(profile_data_url)
        @profile_csrf_headers = {
          'csrf' => page.response['csrf'],
          'csrf_ts' => page.response['csrf_ts']
        }

        @profile_csrf_headers = {
          'csrf' => page.response['csrf'],
          'csrf_ts' => page.response['csrf_ts']
        }

        profile_data = page.content
        parsed_profile_data = JSON.parse(profile_data)

        profiles = []
        parsed_profile_data['provisioningProfiles'].each do |row|
          profile = ProvisioningProfile.new
          profile.name = row['name']
          profile.type = type
          profile.platform = platform
          profile.status = row['status']
          profile.expiration = (Time.parse(row['dateExpire']) rescue nil)
          profile.download_url = "https://developer.apple.com/account/#{platform}/profile/profileContentDownload.action?displayId=#{row['provisioningProfileId']}"
          profile.edit_url = "https://developer.apple.com/account/#{platform}/profile/profileEdit.action?provisioningProfileId=#{row['provisioningProfileId']}"
          profile.identifier = row['UUID']
          profiles << profile
        end

        profiles
      end

      def download_profile(profile)
        ext = (profile.platform == :ios) ? 'mobileprovision' : 'provisionprofile'
        self.pluggable_parser.default = Mechanize::Download
        download = get(profile.download_url)
        download.save!(::File.expand_path("~/Library/MobileDevice/Provisioning Profiles/#{profile.identifier}.#{ext}"))
        download.filename
      end

      private

      def login!
        if form = page.forms.first
          form.fields_with(type: 'text').first.value = self.username
          form.fields_with(type: 'password').first.value = self.password

          form.submit
        end
      end

      def select_team!
        if form = page.form_with(:name => 'saveTeamSelection')
          team_option = form.radiobutton_with(:value => self.team_id)
          team_option.check

          button = form.button_with(:name => 'action:saveTeamSelection!save')
          form.click_button(button)
        end
      end
    end
  end
end
