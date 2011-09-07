require 'rubygems'
require 'bundler'
Bundler.setup :default, :test

require 'minitest/autorun'
require 'minitest/spec'
require 'wrong/adapters/minitest'

ENV['RACK_ENV'] = 'test'
