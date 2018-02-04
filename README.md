# Daily Slack Bot

Daily Slack Bot (DSB) is simple slack bot written in Ruby which sends very important information to your slack channel(s):

- Exchange rates
- Day info
- Weather
- Lunches

DSB sends information daily on the time you set in configuration and you can invoke it by typing `bot report` in your Slack channel.

# Configuration

To configure DSB use `config.env` file. 

#### Slack

1. Create a [new bot](https://my.slack.com/services/new/bot) and set its API token ->  `SLACK_API_TOKEN=<api_token>`
2. Set Slack channels to receive daily messages -> `SLACK_DAILY_CHANNELS="#channel1,#channel2"`
3. Invite bot to your channels (type _/invite @<bot-name>_ in each Slack channel)
4. Set hour of daily message `REPORT_HOUR=10`
5. Set minute of daily message `REPORT_MINUTE=0`

#### Zomato (optional)

If you wish to receive daily menus from Zomato restaurants you need to add Zomato API key and set restaurants. 

1. Set Zomato API key ([get](https://developers.zomato.com/api)) -> `ZOMATO_API_KEY=<api_key>`

You can try to fill Zomato restaurant urls and set experimental setting to 1: 

2. `ZOMATO_RESTAURANT_EXPERIMENTAL=1` 
3. `ZOMATO_RESTAURANT_URLS=http://www.zomato.com/restaurant1,http://www.zomato.com/restaurant2`

DSB tries to scrape Zomato restaurant ID and name from Zomato website, **HOWEVER** most of the time the request is denied by Zomato server. In that case you can get ids and names by running
```bash
ruby zomato_info.rb -u <urls>
```
on your computer (`urls` are Zomato retaurant urls joined with `,` (comma)) or find it yourself. After getting ids and names continue with:

2. Set Zomato restaurant ids -> `ZOMATO_RESTAURANT_IDS=1,2,3`
3. Set Zomato restaurant names -> `ZOMATO_RESTAURANT_NAMES=Restaurant One,Restaurant Two`

If you won't set restaurant urls nor ids and names you won't get daily menus sent to your Slack.

#### Weather (optional)

If you wish to be informed about weather conditions:

1. Set OpenWeatherMap API key ([get](https://openweathermap.org/appid)) `OPEN_WEATHER_API_KEY=<api_key>`
2. Set location coordinates `WEATHER_LOCATION=95.2,108.4`

If you won't set API key or weather location you won't get weather info.

#### Rates (optional)

If you wish to be informed about exchange rates:

1. Set base currency `RATES_BASE=EUR`
2. Set exchange currencies `RATES=GBP`

If you won't set base currency or exchange currencies you won't get exchange rates.

#### Day info (optional)

If you wish to be informed about day info (sunrise, sunset, day length):

1. Set location coordinates `DAY_INFO_LOCATION=95.2,108.4`

If you won't set location coordinates you won't get day info.

# Run

You can deploy and run DSB on [Heroku](https://www.heroku.com/home) for free.

1. [Sign up](https://www.heroku.com/home)
2. [Install Heroku CLI and login](https://devcenter.heroku.com/articles/heroku-cli)
3. [Create Heroku app and deploy](https://devcenter.heroku.com/articles/git#creating-a-heroku-remote)
