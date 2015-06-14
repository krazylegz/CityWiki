require 'sinatra'
require 'json'
require 'unirest'
require 'geocoder'

set :port, 8080
key = File.read("keystore")

get '/' do
  "citywiki => type http://localhost:8080/tampa+fl as an address url and press enter."
end

get '/:id+:state' do
  content_type :json

  wiki_uri = URI.parse(URI.encode("http://en.wikipedia.org/w/api.php?action=query&prop=extracts|info&exintro&titles=#{params['id']}+#{params['state']}&format=json&explaintext&redirects&inprop=url&indexpageids".strip)).to_s
  wiki_response = Unirest.get wiki_uri,
                              headers: {
                                "X-Mashape-Key" => key,
                                "Accept" => "application/json"
                              }
  wiki_data = JSON.parse(wiki_response.body.to_json) || "Wiki data not found from query!"
  wiki_page_id = wiki_data["query"]["pageids"][0] || "Wiki page id was not found from query!"
  wiki_title = wiki_data["query"]["pages"][wiki_page_id]["title"] || "Title was not found from query!"
  wiki_info = wiki_data["query"]["pages"][wiki_page_id]["extract"] || "Info was not found from query!"
  wiki_url = wiki_data["query"]["pages"][wiki_page_id]["fullurl"] || "Url was not returned from query!"

  city = Geocoder.search("#{params['id']}, #{params['state']}")
  latitude = city[0].latitude.to_s
  longitude = city[0].longitude.to_s

  weather_uri = "https://simple-weather.p.mashape.com/weatherdata?lat=" + latitude + "&lng=" + longitude
  weather_response = Unirest.get weather_uri,
                                 headers:{
                                   "X-Mashape-Key" => key,
                                   "Accept" => "application/json"
                                 }
  weather_data = JSON.parse(weather_response.body.to_json)
  weather_forecast = weather_data["query"]["results"]["channel"]["item"]["forecast"]

  json = JSON.generate({ :city => wiki_title, :geo => [:latitude => latitude, :longitude => longitude], :weather_forcast => weather_forecast, :info => wiki_info, :url => wiki_url })
end
