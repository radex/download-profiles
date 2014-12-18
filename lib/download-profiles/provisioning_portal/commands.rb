include Cupertino::ProvisioningPortal

require 'download-profiles/provisioning_portal/helpers'
include Cupertino::ProvisioningPortal::Helpers

global_option('-u', '--username USER', 'Username') { |arg| agent.username = arg unless arg.nil? }
global_option('-p', '--password PASSWORD', 'Password') { |arg| agent.password = arg unless arg.nil? }
global_option('--team TEAM', 'Team') { |arg| agent.team = arg if arg }
global_option('--info', 'Set log level to INFO') { agent.log.level = Logger::INFO }
global_option('--debug', 'Set log level to DEBUG') { agent.log.level = Logger::DEBUG }
global_option('--format FORMAT', [:table, :csv], "Set output format (default: table)")

require 'download-profiles/provisioning_portal/commands/profiles'
require 'download-profiles/provisioning_portal/commands/login'
require 'download-profiles/provisioning_portal/commands/logout'
