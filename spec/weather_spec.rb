require 'spec_helper'
require_relative '../app/weather'

RSpec.describe(Weather) do
  describe '#latitude' do
    it 'returns latitude' do
      weather = Weather.new(latitude: '39.897047', longitude: '-76.1635655')

      expect(weather.latitude).to eql('39.897047')
    end
  end

  describe '#longitude' do
    it 'returns longitude' do
      weather = Weather.new(latitude: '39.897047', longitude: '-76.1635655')

      expect(weather.longitude).to eql('-76.1635655')
    end
  end

  describe '#request' do
    it 'creates a request URL' do
      weather = Weather.new(latitude: '39.897047', longitude: '-76.1635655')

      expect(weather.request).to eql(
        'https://simple-weather.p.mashape.com/weatherdata?lat=39.897047' \
        '&lng=-76.1635655'
      )
    end
  end

  describe '#response' do
    it 'requests data' do
      weather = Weather.new(latitude: '39.897047', longitude: '-76.1635655')

      expect(weather.response.body).to be_a_kind_of(Hash)
    end
  end

  describe '#json' do
    it 'returns parsed JSON' do
      weather = Weather.new(latitude: '39.897047', longitude: '-76.1635655')

      expect(weather.json).to be_a_kind_of(Hash)
    end
  end
end
