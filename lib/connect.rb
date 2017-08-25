
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

def create_scan(name, name_s, file)
  r = listPolicies("policies","name", "sil")
  @uuid=""
  r["policies"].each do | h |
    #binding.pry
    if h["name"] == name
      @uuid = h["template_uuid"]
      @id = h["id"]
      #binding.pry
    end
  end
  if @uuid == ""
    puts "No encontre la Politica #{name} "
    exit
  end
#  puts body
  h1 = "X-Cookie: token=#{@n_config['nessus-server']['token']}"
  h2 = "Content-Type: application/json"
  c_url = "https://#{@n_config['nessus-server']['host']}/scans"
  #binding.pry
  lines = Array.new
  ip = File.readlines("#{file}").each { |line| lines << line }
  block = ip.each_slice(16).to_a
  block.each.with_index(1) do | ips, index |
    targets = ips.join.gsub("\n",", ")
    body = JSON.dump({
      "uuid" =>  "#{@uuid}",
      "settings" => {
        "name" =>  "#{index}-#{name_s}",
        "policy_id": "#{@id}",
        "enabled" => "true",
        "text_targets" =>  "#{targets.chomp(', ')}"
      }
    })
    #puts targets
    #binding.pry
    out = %x[curl -s -k -X POST -H \"#{h1}\" -H \"#{h2}\" -d \'#{body}\' #{c_url}]
    out = JSON.parse(out)
    puts "Creado: #{out["scan"]["name"]}  n_targets: #{out["scan"]["custom_targets"].split(",").size}"
    #binding.pry
  end
end
