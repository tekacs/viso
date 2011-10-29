require 'rubygems'
require 'bundler'
Bundler.setup :default, :test

require 'minitest/autorun'
require 'minitest/spec'
require 'wrong/adapters/minitest'

ENV['RACK_ENV'] = 'test'

class MiniTest::Unit::TestCase
  def self.subject(&block)
    define_method :subject do
      @subject ||= block.call
    end
  end
end
