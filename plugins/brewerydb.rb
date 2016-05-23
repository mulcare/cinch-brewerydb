require 'net/http'
require 'json'


class Cinch::BreweryDB
  include Cinch::Plugin

  listen_to :connect,  :method => :setup

  def setup(*)
    @brewerydb_api_key = config[:brewerydb_api_key]
    @brewerydb_api_url = "http://api.brewerydb.com/v2/beers"
  end

  def search(beer_name)
    url = "#{@brewerydb_api_url}/?key=#{@brewerydb_api_key}&format=JSON&name=#{beer_name}&withBreweries=y"
    uri = URI(url)
    response = Net::HTTP.get(uri)
    beer_info = JSON.parse(response)

    # Set useful variables from the JSON response
    @beer_name = beer_info["data"][0]["name"]
    @beer_brewery = beer_info["data"][0]["breweries"][0]["name"]
    @beer_city = beer_info["data"][0]["breweries"][0]["locations"][0]["locality"]
    @beer_state = beer_info["data"][0]["breweries"][0]["locations"][0]["region"]
    @beer_abv = beer_info["data"][0]["abv"]
    @beer_ibu = beer_info["data"][0]["ibu"]
    @beer_style = beer_info["data"][0]["style"]["shortName"]
  end

  match /beer (.+)/
  def execute(m, query)
    search(query)
    m.reply "#{@beer_name} by #{@beer_brewery} (#{@beer_city}, #{@beer_state})"
    m.reply "#{@beer_style} - #{@beer_abv}% ABV - #{@beer_ibu} IBU 🍻"
  rescue
    m.reply "\"#{query}\" not found. Try full name of beer."
  end
end
