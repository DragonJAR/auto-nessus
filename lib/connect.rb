
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

def listPolicies(feature,name)
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
      puts table
    else
      @rows = []
      t["#{feature}"].each.with_index(1) { | a,  index | @rows << [index, a["#{name}"] ] }
      table = Terminal::Table.new :headings => ['N',  'NOMBRE'], :rows => @rows
      puts table
    end
    #puts JSON.pretty_generate(t["templates"]["title"])
  end
end

def post()
  JSON.dump({
    "uuid": {template_uuid},
    "settings": {
        "name": {string},
        "description": {string},
        "emails": {string},
        "enabled": "true",
        "launch": {string},
        "folder_id": {integer},
        "policy_id": {integer},
        "scanner_id": {integer},
        "text_targets": {string}
    }
})

end
