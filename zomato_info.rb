require 'rest-client'
require 'optparse'

URLS = []

OptionParser.new do |opts|
  opts.on('-uURLS', '--urls=URLS', 'Zomato restaurant urls') do |v|
    URLS.concat(v.split(','))
  end

end.parse!

def zomato_info(url)
  RestClient.get(url, :'user-agent' => 'daily-slack/0.0.1') do |response|
    meta_link = response.to_s[/zomato:\/\/r\/[0-9]+/]
    name = response.to_s.match(/(class="ui large header left">\s*)(.*)(\s*<\/a>)/)
    name.nil? ? name = url : name = name.captures[1]
    meta_link = meta_link[11..-1] unless meta_link.nil?
    return meta_link, name
  end
end

def print_info
  ids = []
  names = []
  URLS.each {|url|
    id, name = zomato_info url
    ids << id
    names << name
  }
  puts ids.join(',')
  puts names.join(',')
end

print_info