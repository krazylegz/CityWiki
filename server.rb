require 'sinatra'
require 'unirest'
require 'haml'

set :port, 8080

key = File.read("keystore")

get '/' do
  haml :index
end

get '/api/:id' do
  response = Unirest.get "https://community-wikipedia.p.mashape.com/api.php?action=query&format=json&prop=revisions&rvprop=content&titles=#{params['id']}",
                         headers: {
                           "X-Mashape-Key" => key,
                           "Accept" => "application/json"
                         }

  latitude = response[0]
  longiture = response[1]

  response = Unirest.get "https://simple-weather.p.mashape.com/weatherdata?lat=" + latitude + "&lng=" + longitude,
                         headers:{
                           "X-Mashape-Key" => "l0kmxTytl7mshwOMflAD8VvjnlyOp1nlv2Djsnuc2v2IJ5SRNr",
                           "Accept" => "application/json"
                         }
end
