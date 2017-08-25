# AUTO-NESSUS
CMD Client Nessus
```
  __ _ _   _| |_ ___        _ __   ___  ___ ___ _   _ ___
 / _` | | | | __/ _ \ _____| '_ \ / _ \/ __/ __| | | / __|
| (_| | |_| | || (_) |_____| | | |  __/\__ \__ \ |_| \__ \
 \__,_|\__,_|\__\___/      |_| |_|\___||___/___/\__,_|___/
                            Born in the community DragonJar

```

## Installation

Clone and install dependencies

   1.  `git clone git@github.com:luisra51/auto-nessus.git`
   2.  `cd auto-nessus`
   3.  `bundle install`

# Note: require native command curl

## Config
  1.  `cp config.json.example config.json`
  2.  Edit and add : host, username, password.
  3.  `ruby auto-nessus.rb login`

## Usage

  show file [help.txt](help.txt) or use `ruby auto-nessus.rb help`

## TODO
  1. create and delete policies, folders, scanners, etc.
  2. launch scanns
  3. send actions start, stop and pause to scanns
  4. change create scans curl to ruby

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
