require 'sinatra'
require 'json'
require 'geocoder'

require_relative 'app/city_wiki'

set :port, 8080

get '/' do
  'Type localhost:8080/new%20york+ny or localhost:8080/tampa+fl in the address bar and press enter.'
end

get '/:city+:state' do
  content_type :json

  @city = "#{params['city']}"
  @state = "#{params['state']}"

  cityWiki = CityWiki.new(params)
  cityWiki.json
end
