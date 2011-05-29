require 'em-synchrony'
require 'em-synchrony/em-http'
require 'ostruct'
require 'pygments'
require 'redcarpet'
require 'yajl'

class Drop < OpenStruct

  include Pygments

  class NotFound < StandardError; end

  def self.base_uri
    @@base_uri
  end
  @@base_uri = ENV.fetch 'CLOUDAPP_DOMAIN', 'api.cld.me'

  def self.find(slug)
    request = EM::HttpRequest.new("http://#{ base_uri }/#{ slug }").
                              get(:head => { 'Accept'=> 'application/json' })

    raise NotFound unless request.response_header.status == 200

    Drop.new Yajl::Parser.parse(request.response)
  end

  def bookmark?
    item_type == 'bookmark'
  end

  def image?
    item_type == 'image'
  end

  def text?
    item_type == 'text' || markdown?
  end

  def markdown?
    extensions = %w( .md .mdown .markdown )

    item_type == 'unknown' && extensions.include?(File.extname(content_url))
  end

  def code?
    lexer_name_for :filename => content_url
  rescue RubyPython::PythonError
    false
  end

  def content
    return unless text? || markdown?

    raw = EM::HttpRequest.new(content_url).get(:redirects => 3).response
    if markdown?
      Redcarpet.new(raw).to_html
    else
      raw
    end
  end

  def data
    marshal_dump
  end

end
