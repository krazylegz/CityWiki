require 'sinatra'
require 'wikipedia'
require 'unirest'
require 'haml'

set :port, 8080

key = File.read("keystore")

get '/' do
  haml :index
end

get '/api/:id' do
  # get wikipedia request
  wiki_request = Wikipedia.find( "#{params['id']}" )
  wiki_data = wiki_request.raw_data

  puts wiki_request.title
  info = wiki_request.content
  latitude = wiki_request.coordinates[0]
  longiture = wiki_request.coordinates[1]

  # weather api
  response = Unirest.get "https://simple-weather.p.mashape.com/weatherdata?lat=" + latitude + "&lng=" + longitude,
                         headers:{
                           "X-Mashape-Key" => key,
                           "Accept" => "application/json"
                         }
end
