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
end
