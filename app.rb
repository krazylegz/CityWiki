require 'sinatra'
require 'json'
require 'unirest'
require 'geocoder'

set :port, 8080

get '/' do
  'Type localhost:8080/new+york or localhost:8080/tampa+fl in the address bar and press enter.'
end

get '/:city+:state' do
  content_type :json

  @city = "#{params['city']}"
  @state = "#{params['state']}"

  build_json
end

private

def key
  File.read('keystore')
end

def build_wikipedia
  wiki = "http://en.wikipedia.org/w/api.php?action=query&prop=extracts|info&exintro&titles="
  wiki += "#{@city}+#{@state}&format=json&explaintext&redirects&inprop=url&indexpageids"
end

def wiki_uri
  URI.parse(URI.encode(build_wikipedia.strip)).to_s
end

def wiki_rest_call
  Unirest.get wiki_uri,
              headers: {
                "X-Mashape-Key" => key,
                "Accept" => "application/json"
              }
end

def wiki_response
  JSON.parse(wiki_rest_call.body.to_json) || "Wiki data not found from query!"
end

def city
  Geocoder.search("#{@city}, #{@state}")
end

def latitude
  city[0].latitude.to_s
end

def longitude
  city[0].longitude.to_s
end

def build_weather
  "https://simple-weather.p.mashape.com/weatherdata?lat=" + latitude + "&lng=" + longitude
end

def weather_response
  Unirest.get build_weather,
              headers:{
                'X-Mashape-Key' => key,
                'Accept' => 'application/json'
              }
end

def build_json
  data = wiki_response
  id = data["query"]["pageids"][0] || "Wiki page id was not found from query!"
  city = data["query"]["pages"][id]["title"] || "Title was not found from query!"
  info = data["query"]["pages"][id]["extract"] || "Info was not found from query!"
  url = data["query"]["pages"][id]["fullurl"] || "Url was not returned from query!"

  weather_data = JSON.parse(weather_response.body.to_json)
  weather_forecast = weather_data["query"]["results"]["channel"]["item"]["forecast"]

  JSON.generate({ :city => city, :geo => [:latitude => latitude, :longitude => longitude],
                  :weather_forcast => weather_forecast, :info => info, :url => url })
end
