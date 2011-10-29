require 'em-synchrony'
require 'em-synchrony/em-http'
require 'ostruct'
require 'pygments'
require 'redcarpet'
require 'yajl'

class Drop < OpenStruct

  include Pygments

  # Heroku's cedar stack raises an "invalid ELF header" exception using the
  # latest version of python (2.7) on the system. python2.6 seems to work fine.
  RubyPython.configure :python_exe => 'python2.6'

  class NotFound < StandardError; end

  def self.base_uri
    @@base_uri
  end
  @@base_uri = ENV.fetch 'CLOUDAPP_DOMAIN', 'api.cld.me'

  def self.find(slug)
    Drop.new Yajl::Parser.parse(fetch_drop_content(slug))
  end

  def subscribed?
    subscribed
  end

  def bookmark?
    item_type == 'bookmark'
  end

  def image?
    %w( bmp
        gif
        ico
        jp2
        jpe
        jpeg
        jpf
        jpg
        jpg2
        jpgm
        png ).include? extension
  end

  def audio?
    item_type == 'audio'
  end

  def video?
    item_type == 'video'
  end

  def text?
    plain_text? || markdown? || code?
  end

  def plain_text?
    lexer_name == 'text'
  end

  def markdown?
    %w( md
        mdown
        markdown ).include? extension
  end

  def code?
    lexer_name && !%w( text postscript minid ).include?(lexer_name)
  end

  def content
    return unless plain_text? || markdown? || code?

    if markdown?
      parse_markdown
    elsif code?
      highlight_code
    else
      raw
    end
  end

  def data
    marshal_dump
  end

private

  def self.fetch_drop_content(slug)
    request = EM::HttpRequest.new("http://#{ base_uri }/#{ slug }").
                              get(:head => { 'Accept'=> 'application/json' })

    raise NotFound unless request.response_header.status == 200

    request.response
  end

  def extension
    File.extname(content_url)[1..-1].to_s.downcase if content_url
  end

  def lexer_name
    @lexer_name ||= lexer_name_for :filename => content_url
  rescue RubyPython::PythonError
    false
  end

  def raw
    @raw ||= EM::HttpRequest.new(content_url).get(:redirects => 3).response
  end

  def parse_markdown
    Redcarpet.new(raw).to_html
  end

  def highlight_code
    if raw.size >= 50_000
      return %{<div class="highlight"><pre>#{ raw }</pre></div>}
    end

    highlight raw, :lexer => lexer_name
  end

end
