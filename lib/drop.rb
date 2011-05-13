require 'json'
require 'httparty'
require 'net/http'
require 'open-uri'
require 'ostruct'
require 'redcarpet'

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

  def text?
    item_type == 'text' || markdown?
  end

  def markdown?
    extensions = %w( .md .mdown .markdown )

    item_type == 'unknown' && extensions.include?(File.extname(remote_url))
  end

  def content
    return unless text? || markdown?

    raw = Kernel::open(remote_url).read
    if markdown?
      Redcarpet.new(raw).to_html
    else
      raw
    end
  end

  def data
    marshal_dump
  end

  class NotFound < StandardError; end

end
