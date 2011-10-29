require 'em-synchrony'
require 'em-synchrony/em-http'
require 'ostruct'
require 'yajl'

class Domain < OpenStruct

  class NotFound < StandardError; end

  def self.base_uri
    @@base_uri
  end
  @@base_uri = ENV.fetch 'CLOUDAPP_DOMAIN', 'api.cld.me'

  def self.find(domain)
    Domain.new Yajl::Parser.parse(fetch_domain_content(domain))
  end

private

  def self.fetch_domain_content(domain)
    request = EM::HttpRequest.new("http://#{ base_uri }/domains/#{ domain }").
                              get(:head => { 'Accept'=> 'application/json' })

    raise NotFound unless request.response_header.status == 200

    request.response
  end

end
