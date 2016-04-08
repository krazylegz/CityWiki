# spec/spec_helper.rb
require 'simplecov'
SimpleCov.start
require 'rspec'

ENV['RACK_ENV'] = 'test'

RSpec.configure { |c| c.include RSpecMixin }
