require 'sinatra'
require 'json'
require 'unirest'
require 'cities'

set :port, 8080
key = File.read("keystore")

get '/' do
  "citywiki => type http://localhost:8080/tampa as an address url and press enter."
end

get '/:id' do
  content_type :json

  wiki_uri = URI.parse(URI.encode("http://en.wikipedia.org/w/api.php?action=query&prop=extracts|info&exintro&titles=#{params['id']}&format=json&explaintext&redirects&inprop=url&indexpageids".strip)).to_s
  wiki_response = Unirest.get wiki_uri,
                              headers: {
                                "X-Mashape-Key" => key,
                                "Accept" => "application/json"
                              }
  wiki_data = JSON.parse(wiki_response.body.to_json)
  wiki_page_id = wiki_data["query"]["pageids"][0]
  wiki_title = wiki_data["query"]["pages"][wiki_page_id]["title"]
  wiki_info = wiki_data["query"]["pages"][wiki_page_id]["extract"]
  wiki_url = wiki_data["query"]["pages"][wiki_page_id]["fullurl"]

  Cities.data_path = './data/'
  cities = Cities.cities_in_country('US')
  city = cities["#{params['id']}"]
  latitude = city.latlong[0].to_s
  longitude = city.latlong[1].to_s

  weather_uri = "https://simple-weather.p.mashape.com/weatherdata?lat=" + latitude + "&lng=" + longitude
  weather_response = Unirest.get weather_uri,
                                 headers:{
                                   "X-Mashape-Key" => key,
                                   "Accept" => "application/json"
                                 }
  #puts weather_response.body
  json = JSON.generate({ :city => wiki_title, :geo => [:latitude => latitude, :longitude => longitude], :info => wiki_info, :url => wiki_url })
end
