require 'slack-ruby-client'
require 'dotenv'
require 'rufus-scheduler'
require_relative 'api'
require_relative 'zomato_info'

Dotenv.load('config.env')

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

scheduler = Rufus::Scheduler.new
@client = Slack::RealTime::Client.new

def lunch_header(name)
  header = "=======================================\n"
  header += "#{name}\n"
  header += "-------------------------------------------------------------\n"
  header
end

def lunches
  experimental = ENV['ZOMATO_RESTAURANT_EXPERIMENTAL']
  return lunches_experimental if experimental == '1'
  names = ENV['ZOMATO_RESTAURANT_NAMES'].split(',')
  ids = ENV['ZOMATO_RESTAURANT_IDS'].split(',')
  return unless ids.any?
  ret = ''
  ids.each_with_index do |id, index|
    ret += lunch_header names[index]
    ret += Api.lunch id
    ret += "\n\n"
  end
  ret
end

def lunches_experimental
  urls = ENV['ZOMATO_RESTAURANT_URLS'].split(',')
  return unless urls.any?
  ret = ''
  urls.each do |url|
    id, name = zomato_info url
    ret += lunch_header name
    if id.nil?
      ret += "(unable to get id of #{url}"
    else
      ret += Api.lunch id
    end
    ret += "\n\n"
  end
  ret
end

def rates
  base = ENV['RATES_BASE']
  rates = ENV['RATES'].split(',')
  Api.currency_rates(base, rates) if rates.any? && !base.empty?
end

def day_info
  coordinates = ENV['DAY_INFO_LOCATION'].split(',')
  Api.day_info coordinates[0], coordinates[1] if coordinates.any?
end

def weather
  coordinates = ENV['WEATHER_LOCATION'].split(',')
  Api.weather coordinates[0], coordinates[1] if coordinates.any?
end

def attachments
  attachments = []

  m_rates = rates
  m_day_info = day_info
  m_weather = weather
  m_lunches = lunches

  unless m_rates.nil?
    attachments << {
        title: 'Rates',
        text: m_rates,
        color: ENV['RATES_COLOR']
    }
  end

  unless m_day_info.nil?
    attachments << {
        title: 'Day info',
        text: m_day_info,
        color: ENV['DAY_INFO_COLOR']
    }
  end

  unless m_weather.nil?
    attachments << {
        title: 'Weather',
        text: m_weather,
        color: ENV['WEATHER_COLOR']
    }
  end

  unless m_lunches.nil?
    attachments << {
        title: 'Lunches',
        text: m_lunches,
        color: ENV['LUNCHES_COLOR']
    }
  end

  attachments
end

def report(channels)
  channels.each do |channel|
    begin
      @client.web_client.chat_postMessage(channel: channel, as_user: true, attachments: attachments)
    rescue
      puts "Unable to report to channel #{channel} || ERROR: #{$ERROR_INFO}"
    end
  end
end

@client.on :message do |data|
  case data.text
    when 'bot report' then
      report [data.channel]
    when /^bot/ then
      @client.web_client.chat_postMessage channel: [data.channel], text: "Sorry <@#{data.user}>, I can only do report"
  end
end

scheduler.cron "#{ENV['REPORT_MINUTE']} #{ENV['REPORT_HOUR']} * * *" do
  report ENV['SLACK_DAILY_CHANNELS'].split(',')
end

@client.start!