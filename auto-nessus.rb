#!/usr/bin/env ruby
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
  when "create_scans"
    #binding.pry
    if ARGV[1].nil?
      puts "Ingresa nombre de la POLITICA"
      puts "[exp:~$] ruby auto-nessus.rb create_scan <NAME-POLICIES> <NAME-SCAN> <FILE> "
      exit
    end
    if ARGV[2].nil?
      puts "Ingresa nombre de la SCAN"
      puts "[exp:~$] ruby auto-nessus.rb create_scan <NAME-POLICIES> <NAME-SCAN> <FILE>"
      exit
    end
    if ARGV[3].nil?
      puts "Ingresa nombre del ARCHIVO IP"
      puts "[exp:~$] ruby auto-nessus.rb create_scan <NAME-POLICIES> <NAME-SCAN> <FILE>"
      exit
    end
    create_scan(ARGV[1],ARGV[2], ARGV[3])
  else
    help = File.read("help.txt")
    #puts "Opcion no valida"
    puts help
  end
