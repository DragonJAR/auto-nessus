
def nessus_server_post(url, body, t)
  #binding.pry
  uri = URI.parse("https://#{@n_config["nessus-server"]["host"]}/#{url}")
  request = Net::HTTP::Post.new(uri)
  request.content_type = "application/json"
  request["X-Cookie"] = "#{t}"
  request.body = body

  req_options = {
    use_ssl: uri.scheme == "https",
    verify_mode: OpenSSL::SSL::VERIFY_NONE,
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end
  return response
end

def nessus_server_get(url)
  #binding.pry
  uri = URI.parse("https://#{@n_config["nessus-server"]["host"]}/#{url}")
  request = Net::HTTP::Get.new(uri)
  request.content_type = "application/json"
  request["X-Cookie"] = "token=#{@n_config["nessus-server"]["token"]}"

  req_options = {
    use_ssl: uri.scheme == "https",
    verify_mode: OpenSSL::SSL::VERIFY_NONE,
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end
  return response
end


def login

  body = JSON.dump({
    "username" => @n_config["nessus-server"]["username"],
    "password" => @n_config["nessus-server"]["password"]
  })
  token = nessus_server_post("session", body, "" )
  t = JSON.parse(token.body)
  #binding.pry
  @n_config["nessus-server"]["token"] = t["token"]
  edit_f =  File.open("config.json","w")
  edit_f.write(JSON.pretty_generate(@n_config))
  edit_f.close
  puts token.code
end

def listPolicies(feature,name, mode)
  body = ""
  list = nessus_server_get(feature)
  #binding.pry
  if list.code == "401"
    puts list.body
  else
    t = JSON.parse(list.body)
    #binding.pry
    if feature == "scans"
      @rows = []
      t["#{feature}"].each.with_index(1) { | a,  index | @rows << [index, a["id"], a["#{name}"] ]  }
      table = Terminal::Table.new :headings => ['N', 'ID', 'NOMBRE'], :rows => @rows
      puts table if mode != "sil"
    else
      @rows = []
      t["#{feature}"].each.with_index(1) { | a,  index | @rows << [index, a["#{name}"] ] }
      table = Terminal::Table.new :headings => ['N',  'NOMBRE'], :rows => @rows
      puts table if mode != "sil"
    end
    #puts JSON.pretty_generate(t["templates"]["title"])
    return t
  end
end

def create_scan(name)

  r = listPolicies("policies","name", "sil")
  #binding.pry
  r["policies"].each do | h |
    if h["name"] == name
      @uuid = h["template_uuid"]

    else
      puts "Ingresa el nombre de la Politica"
      exit
    end
  end
  body = JSON.dump({
    "uuid" =>  @uuid ,
    "settings" => {
      "name" =>  "string",
      "description" =>  "string",
      "emails" =>  "string",
      "enabled" => "true",
      "launch" =>  "string",
      "folder_id" =>  "integer",
      "policy_id" =>  "integer",
      "scanner_id" =>  "integer",
      "text_targets" =>  "string"
    }
  })
  puts body

  #r = nessus_server_post("/scans", body, "" )
  #t = JSON.parse(r.body)
  #puts r.body

end
