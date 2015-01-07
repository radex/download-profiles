require 'mechanize'
require 'certified'

module Cupertino
  module ProvisioningPortal
    HOST = "developer.apple.com"

    class UnsuccessfulAuthenticationError < RuntimeError; end
    class UnexpectedContentError < RuntimeError; end

    class ProvisioningProfile < Struct.new(:name, :type, :platform, :app_id, :status, :expiration, :download_url, :edit_url, :identifier)
      def to_s
        "#{self.name}"
      end
    end
  end
end

require 'download-profiles/provisioning_portal/agent'
