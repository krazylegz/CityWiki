class Wikipedia
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

  def url
    "http://en.wikipedia.org/w/api.php?action=query&prop=extracts|info&exintro&titles=#{city},%20#{state}&format=json&explaintext&redirects&inprop=url&indexpageids"
  end

  def request 
    URI.parse(URI.encode(url.strip)).to_s
  end

  def response
    Unirest.get url,
      headers: {
        'X-Mashape-Key' => key,
        'Accept' => 'application/json'
      }
  end

  def json
    JSON.parse(response.body.to_json) || 'Wiki data not found from query!'
  end
end
