require 'cinch'
require_relative 'plugins/brewerydb'

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.server.net"
    c.channels = ["#channel_name"]
    c.nick = "bot_nick"
    
    c.plugins.plugins = [
      Cinch::BreweryDB
    ]

    c.plugins.options[Cinch::BreweryDB] = {
        :brewerydb_api_key => "",
      }
  end

end

bot.start
