require 'em-synchrony'
require 'em-synchrony/em-http'
require 'ostruct'
require 'yajl'

class Domain < OpenStruct

  class NotFound < StandardError; end

  def self.base_uri
    @@base_uri
  end
  @@base_uri = ENV.fetch 'CLOUDAPP_DOMAIN', 'api.cld.local' #'api.cld.me'

  def self.find(domain)
    request = EM::HttpRequest.new("http://#{ base_uri }/domains/#{ domain }").
                              get(:head => { 'Accept'=> 'application/json' })

    raise NotFound unless request.response_header.status == 200

    Domain.new Yajl::Parser.parse(request.response)
  end

end
