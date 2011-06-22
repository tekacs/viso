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

  def audio?
    item_type == 'audio'
  end

  def video?
    item_type == 'video'
  end

  def text?
    extension == '.txt'
  end

  def markdown?
    %w( .md .mdown .markdown ).include? extension
  end

  def code?
    !!lexer_name
  end

  def subscribed?
    subscribed
  end

  def content
    return unless text? || markdown? || code?

    raw = EM::HttpRequest.new(content_url).get(:redirects => 3).response
    if markdown?
      Redcarpet.new(raw).to_html
    elsif code?
      highlight raw, :lexer => lexer_name
    else
      raw
    end
  end

  def data
    marshal_dump
  end

private

  def extension
    File.extname content_url
  end

  def lexer_name
    return if text?

    lexer_name_for :filename => content_url
  rescue RubyPython::PythonError
    false
  end

end
