$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'netsuite_client/string'
require 'netsuite_client/symbol'

require 'rubygems'
gem 'soap4r'

DEFAULT_NS_WSDL_VERSION = '2011_2'
if ENV['FORCE_NS_WSDL_VERSION'] 
  begin
    require "netsuite_client/soap_netsuite_#{ENV['FORCE_NS_WSDL_VERSION']}"
  rescue LoadError
    puts "Error loading WSDL #{ENV['FORCE_NS_WSDL_VERSION']}, trying to load default WSDL: #{DEFAULT_NS_WSDL_VERSION}"
    require "netsuite_client/soap_netsuite_#{DEFAULT_NS_WSDL_VERSION}"
  end
else
  require "netsuite_client/soap_netsuite_#{DEFAULT_NS_WSDL_VERSION}"
end

require 'netsuite_client/netsuite_exception'
require 'netsuite_client/netsuite_result'
require 'netsuite_client/client'

class NetsuiteClient
  VERSION = '1.0'
end
