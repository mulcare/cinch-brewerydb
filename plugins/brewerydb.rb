# = Cinch BreweryDB API query plugin
# Queries the BreweryDB beer database (http://www.brewerydb.com/) with the
# name of a beer and returns some information about that beer.
#
# == Configuration
# Add the following to your bot's configure.do stanza:
#
#   config.plugins.options[Cinch::BreweryDB] = {
#     :brewerydb_api_key => ""
#   }
#
# [brewerydb_api_key]
#   API keys are available after creating an account on brewerydb. See:
#   http://www.brewerydb.com/developers/apps
#
# == Author
# Ross Mulcare (@mulcare)
#
# == Notes
# Thanks to Marvin Gülker (Quintus) for his numerous Cinch plugins that I have
# learned and borrowed from. The above comments/documentation are cribbed from
# his style. See: https://github.com/Quintus/cinch-plugins
#
# == License
# The MIT License (MIT)
# Copyright (c) 2016 Ross Mulcare
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'net/http'
require 'json'

class Cinch::BreweryDB
  include Cinch::Plugin

  listen_to :connect,  :method => :setup

  def setup(*)
    @brewerydb_api_key = config[:brewerydb_api_key]
    @brewerydb_api_url = "http://api.brewerydb.com/v2/search"
  end

  def search(beer_name)
    url = "#{@brewerydb_api_url}/?q=#{beer_name}&type=beer&withBreweries=y&key=#{@brewerydb_api_key}&format=json"
    uri = URI(URI.escape(url))
    response = Net::HTTP.get(uri)
    beer_info = JSON.parse(response)

    # Set useful variables from the JSON response
    @beer_name = beer_info["data"][0]["name"]
    @beer_brewery = beer_info["data"][0]["breweries"][0]["name"]
    @beer_city = beer_info["data"][0]["breweries"][0]["locations"][0]["locality"]
    @beer_state = beer_info["data"][0]["breweries"][0]["locations"][0]["region"]
    @beer_abv = beer_info["data"][0]["abv"]
    @beer_ibu = beer_info["data"][0]["ibu"]
    if @beer_ibu.nil?
      @beer_ibu = 0
    end
    @beer_style = beer_info["data"][0]["style"]["shortName"]
  end

  match /beer (.*)/
  def execute(m, query)
    beer = search(query)
    m.reply "#{Format(:12, @beer_name)} by #{@beer_brewery} (#{@beer_city}, #{@beer_state})"
    m.reply "#{@beer_style} - #{@beer_abv}% ABV - #{@beer_ibu} IBU 🍻"
  rescue
    m.reply "\"#{query}\" not found. Try full name of beer."
  end
end
