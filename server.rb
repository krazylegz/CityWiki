require 'sinatra'
require 'json'
require 'unirest'
require 'cities'

set :port, 8080
key = File.read("keystore")

get '/' do
  "citywiki => type http://localhost:8080/tampa+fl as an address url and press enter."
end

get '/:id+:state' do
  content_type :json

  Cities.data_path = './data/'
  cities = Cities.cities_in_country('US')
  latitude = cities.find {|city| city["#{params['id']}"].region == "#{params['state']}"}['latitude'].to_i
  longitude = cities["#{params['id']}"].find {|state| state['region'] == "#{params['state']}"}['longitude'].to_i

  wiki_uri = URI.parse(URI.encode("http://en.wikipedia.org/w/api.php?action=query&prop=extracts|info&exintro&titles=#{params['id']}+#{params['state']}&format=json&explaintext&redirects&inprop=url&indexpageids".strip)).to_s
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

  weather_uri = "https://simple-weather.p.mashape.com/weatherdata?lat=" + latitude + "&lng=" + longitude
  weather_response = Unirest.get weather_uri,
                                 headers:{
                                   "X-Mashape-Key" => key,
                                   "Accept" => "application/json"
                                 }
  weather_data = JSON.parse(weather_response.body.to_json)
  weather_results = weather_data["query"]["results"]
  puts weather_response.body
  json = JSON.generate({ :city => wiki_title, :geo => [:latitude => latitude, :longitude => longitude], :info => wiki_info, :url => wiki_url })
end
