require 'rest-client'
require 'json'
require 'date'


class Api
  class << self
    def currency_rates(base, rates)
      RestClient.get("http://api.fixer.io/latest?base=#{base}") do |response|
        case response.code
        when 200
          json = JSON.parse response
          ret = "1 #{base}"
          rates.each do |rate|
            ret += " = #{json['rates'][rate]} #{rate}"
          end
          ret
        else
          '(unable to get currency rates)'
        end
      end
    end

    def lunch(restaurant_id)
      RestClient::Request.execute(method: :get, url: "https://developers.zomato.com/api/v2.1/dailymenu?res_id=#{restaurant_id}", headers: { user_key: ENV['ZOMATO_API_KEY'] }) do |response|
        case response.code
        when 200
          json = JSON.parse response
          daily_menus = json['daily_menus']
          return '(restaurant did not provide daily menu)' if daily_menus.empty?
          daily_menu = json['daily_menus'][0]['daily_menu']
          menu_date = DateTime.parse(daily_menu['start_date']).strftime('%A, %d.%m.%Y')
          dishes = daily_menu['dishes']
          ret = dishes.map { |dish| "\n#{dish['dish']['name'].strip}" }.to_sentence[1..-1]
          "(#{menu_date})\n#{ret}"
        else
          '(unable to get lunches)'
        end
      end
    end

    def day_info(lat, lng)
      RestClient.get('https://api.sunrise-sunset.org/json', params: { lat: lat, lng: lng }) do |response|
        case response.code
        when 200
          json = JSON.parse response
          sunrise = DateTime.parse(json['results']['sunrise']).localtime.strftime('%H:%M:%S')
          sunset = DateTime.parse(json['results']['sunset']).localtime.strftime('%H:%M:%S')
          day_length = json['results']['day_length']
          "Sunrise: #{sunrise}\nSunset: #{sunset}\nDay length: #{day_length}"
        else
          '(unable to get day info)'
        end
      end
    end

    def weather(lat, lng)
      RestClient.get('api.openweathermap.org/data/2.5/forecast', params: { lat: lat, lon: lng, units: 'metric', APPID: ENV['OPEN_WEATHER_API_KEY'] }) do |response|
        case response.code
        when 200
          json = JSON.parse response
          list = json['list']
          ret = ''
          list.each do |i|
            time = DateTime.parse Time.at(i['dt']).to_s
            next unless time.today?
            temp = i['main']['temp'].round
            weather = i['weather'][0]['description']
            time_formatted = time.localtime.strftime('%H:%M:%S')
            ret += "#{time_formatted}: #{temp}°C, #{weather}\n"
          end
          ret
        else
          '(unable to get weather forecast)'
        end
      end
    end
  end
end
