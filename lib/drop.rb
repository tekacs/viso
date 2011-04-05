require 'json'
require 'httparty'
require 'net/http'
require 'ostruct'

class Drop < OpenStruct
  include  HTTParty
  base_uri ENV.fetch('CLOUDAPP_DOMAIN', 'api.cld.me')

  def self.find(slug)
    response = get "/#{ slug }",
                   :headers => { 'Accept' => 'application/json' }

    raise NotFound.new unless response.ok?

    Drop.new response.parsed_response
  end

  def bookmark?
    item_type == 'bookmark'
  end

  def image?
    item_type == 'image'
  end

  def data
    marshal_dump
  end

  class NotFound < StandardError; end

end
