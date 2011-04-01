require 'json'
require 'httparty'
require 'net/http'

class Viso
  class Drop
    DOMAIN = ENV.fetch 'CLOUDAPP_DOMAIN', 'cl.ly'

    class NotFound < StandardError; end

    def self.find(slug)
      response slug
    end

  protected

    def self.response(slug)
      response = HTTParty.get "http://#{ DOMAIN }/#{ slug }",
                              :headers => { 'Accept' => 'application/json' }

      raise NotFound.new unless response.ok?

      response
    end

  end
end
