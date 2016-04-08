# spec/spec_helper.rb
require 'simplecov'
SimpleCov.start
require 'rspec'

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  def app
    Sinatra::Application
  end
end

RSpec.configure { |c| c.include RSpecMixin }
