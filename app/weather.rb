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
