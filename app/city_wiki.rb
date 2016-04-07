require_relative 'weather'
require_relative 'wikipedia'

class CityWiki
  attr_accessor :city, :state

  def initialize(attributes = {})
    @city = attributes[:city]
    @state = attributes[:state]
  end

  def state
    @state
  end

  def json
     { :city => @city, :geo => [:latitude => latitude, :longitude => longitude],
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
  rescue
    ''
  end

  private

  def wikipedia
    Wikipedia.new(city: @city, state: @state)
  end

  def weather
    Weather.new(latitude: latitude, longitude: longitude)
  end

  def geocoder_request
    Geocoder.search("#{@city}, #{@state}")
  end

  def latitude
    geocoder_request[0].latitude.to_s
  end

  def longitude
    geocoder_request[0].longitude.to_s
  end
end
