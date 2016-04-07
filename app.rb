require 'sinatra'
require 'json'
require 'unirest'
require 'geocoder'

set :port, 8080

def key
  File.read('keystore')
end

get '/' do
  'Type localhost:8080/new+york or localhost:8080/tampa+fl in the address bar and press enter.'
end

get '/:city+:state' do
  content_type :json

  @city = "#{params['city']}"
  @state = "#{params['state']}"

  cityWiki = CityWiki.new(@city, @state)
  cityWiki.json
end

class CityWiki
  attr_accessor :city, :state

  def initialize(attributes = {})
    @city = attributes[:city]
    @state = attributes[:state]
  end

  def city
    @city
  end

  def state
    @state
  end

  def json
     { :city => city, :geo => [:latitude => latitude, :longitude => longitude],
      :weather => forecast, :info => info, :url => info_url }.to_json
  end

  def id
    wikipedia.json['query']['pageids'][0] ||= 'Wiki Page ID was not found from query!'
  end

  def city
    wikipedia.json['query']['pages'][id]['title'] ||= 'City was not found from query!'
  end

  def info
    wikipedia.json['query']['pages'][id]['extract'] ||= 'Info was not found from query!'
  end

  def info_url
    wikipedia.json['query']['pages'][id]['canonicalurl'] ||= 'Url was not returned from query!'
  end

  def forecast
    weather.json['query']['results']['channel']['item']['forecast']
  end

  private

  def wikipedia
    Wikipedia.new(city, state)
  end

  def weather
    Weather.new(city, state)
  end

  def geocoder
    Geocoder.search("#{city}, #{state}")
  end

  def latitude
    geocoder_request[0].latitude.to_s
  end

  def longitude
    geocoder_request[0].longitude.to_s
  end
end

class Wikipedia
  attr_accessor :city, :state

  def initialize(attributes = {})
    @city = attributes[:city]
    @state = attribute[:state]
  end

  def city
    @city
  end

  def state
    @state
  end

  def url
    "http://en.wikipedia.org/w/api.php?action=query&prop=extracts|info&exintro&titles=#{city}+#{state}&format=json&explaintext&redirects&inprop=url&indexpageids"
  end

  def request 
    URI.parse(URI.encode(url.strip)).to_s
  end

  def response
    Unirest.get uri,
      headers: {
        'X-Mashape-Key' => key,
        'Accept' => 'application/json'
      }
  end

  def json
    JSON.parse(response.body.to_json) || 'Wiki data not found from query!'
  end
end

class Weather
  attr_accessor :latitude, :longitude

  def initialize(attributes = {})
    @latitude = attributes[:latitude]
    @longitude = attributes[:longitude]
  end

  def latitude
    @latitude
  end

  def longitude
    @longitude
  end

  def request
    'https://simple-weather.p.mashape.com/weatherdata?lat=' + latitude + '&lng=' + longitude
  end

  def response
    Unirest.get request,
      headers:{
        'X-Mashape-Key' => key,
        'Accept' => 'application/json'
      }
  end

  def json
    JSON.parse(response.body.to_json)
  end
end
