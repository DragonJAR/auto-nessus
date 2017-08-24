require 'net/http'
require 'uri'
require 'json'
require 'openssl'
require 'pry'
require 'terminal-table'
config = File.read('config.json')
@n_config = JSON.parse(config)
#binding.pry
Dir["#{File.dirname(__FILE__)}/lib/*.rb"].each { |f| require f }

case ARGV[0]
  when "login"
    puts "login"
    login
  when "list_policies"
    # policies name
    listPolicies("policies","name", "std")
  when "list_folders"
    listPolicies("folders","name", "std")
  when "list_scanners"
    listPolicies("scanners","name", "std")
  when "list_scans"
    listPolicies("scans","name", "std")
  when "list_users"
    listPolicies("users","username", "std")
  when "create_scan"
    lines = Array.new
    ip = File.readlines('ip.txt').each { |line| lines << line }
    #binding.pry
    #puts a
    create_scan(ARGV[1])
  else
    puts "Opcion no valida"
  end
