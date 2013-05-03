
require 'rubygems'
require 'bundler/setup'
require 'rack/test'

require 'openvpn-status-web'

def status_v1
  text = File.open('examples/status.v1', 'rb') do |f| f.read end
  OpenVPNStatusWeb::Parser::V1.new.parse_status_log text
end

def status_v2
  text = File.open('examples/status.v2', 'rb') do |f| f.read end
  OpenVPNStatusWeb::Parser::V2.new.parse_status_log text
end

def status_v3
  text = File.open('examples/status.v3', 'rb') do |f| f.read end
  OpenVPNStatusWeb::Parser::V3.new.parse_status_log text
end
