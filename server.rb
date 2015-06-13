require 'sinatra'
require 'json'
require 'unirest'

set :port, 8080

key = File.read("keystore")

get '/' do
  "wwiki => type http://localhost:8080/api/New+York as an address url and press enter."
end

get '/api/:id' do
  # define content type
  content_type :json

  # get wikipedia api response
  wiki_response = Unirest.get "http://en.wikipedia.org/w/api.php?action=opensearch&search=At&namespace=0",
                              headers: {
                                "X-Mashape-Key" => key,
                                "Accept" => "application/json"
                              }

  # parse wikipedia data
  wiki_data = JSON.parse(wiki_response)
  info = wiki_data.content
  latitude = wiki_data.coordinates[0]
  longitude = wiki_data.coordinates[1]

  # get weather api response
  weather_response = Unirest.get "https://simple-weather.p.mashape.com/weatherdata?lat=" + latitude + "&lng=" + longitude,
                         headers:{
                           "X-Mashape-Key" => key,
                           "Accept" => "application/json"
                         }

  # parse weather data
  weather_data = JSON.parse(weather_response)

  # create json object from gather data (wiki and weather)
  #JSON.generate()

  # print json data to screen
  { :city => 'value0', :info => 'value1', :latitude => 'value2', :longitude => 'value3' }.to_json

end
