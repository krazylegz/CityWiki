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
  wiki = 'http://en.wikipedia.org/w/api.php?action=query&prop=extracts|info&exintro&titles='
  wiki += "#{@city}+#{@state}&format=json&explaintext&redirects&inprop=url&indexpageids"
end

def wiki_request
  URI.parse(URI.encode(build_wikipedia.strip)).to_s
end

def wiki_response
  Unirest.get wiki_request,
              headers: {
                "X-Mashape-Key" => key,
                "Accept" => "application/json"
              }
end

def wiki_data
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

def weather_request
  "https://simple-weather.p.mashape.com/weatherdata?lat=" + latitude + "&lng=" + longitude
end

def weather_response
  Unirest.get weather_request,
              headers:{
                'X-Mashape-Key' => key,
                'Accept' => 'application/json'
              }
end

def weather_data
  JSON.parse(weather_response.body.to_json)
end

def id
  wiki_data["query"]["pageids"][0] ||= "Wiki Page ID was not found from query!"
end

def city
  wiki_data["query"]["pages"][id]["title"] ||= "City was not found from query!"
end

def info
  wiki_data["query"]["pages"][id]["extract"] ||= "Info was not found from query!"
end

def url
  wiki_data["query"]["pages"][id]["fullurl"] ||= "Url was not returned from query!"
end

def forecast
  weather_data["query"]["results"]["channel"]["item"]["forecast"]
end

def build_json
  JSON.generate({ :city => city, :geo => [:latitude => latitude, :longitude => longitude],
                  :weather_forcast => weather_forecast, :info => info, :url => url })
end
