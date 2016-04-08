require 'request_helper'

describe 'GET /' do
  it 'displays a help message' do
    get('/')

    expect(last_response.body).to eql(
      'Type localhost:8080/new%20york+ny or localhost:8080/tampa+fl in the ' \
      'address bar and press enter.'
    )
  end
end
