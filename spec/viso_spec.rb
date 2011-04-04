require 'spec_helper'
require 'rack/test'
require 'support/vcr'

require 'viso'

describe Viso do

  include Rack::Test::Methods

  def app
    Viso
  end

  it 'redirects the home page to the CloudApp product page' do
    get '/'

    assert last_response.redirect?
    last_response.headers['Cache-Control'].must_equal 'public, max-age=31557600'
    last_response.headers['Location'].must_equal 'http://getcloudapp.com'
  end

  it 'redirects the favicon to the CloudApp favicon' do
    get '/favicon.ico'

    assert last_response.redirect?
    last_response.headers['Cache-Control'].must_equal 'public, max-age=31557600'
    last_response.headers['Location'].must_equal 'http://my.cl.ly/favicon.ico'
  end

  it 'displays an image drop' do
    VCR.use_cassette 'image', :record => :none do
      get '/hhgttg'

      assert last_response.ok?, 'response not ok'
      last_response.headers['Cache-Control'].must_equal 'public, max-age=900'

      image_tag = %{<img alt="cover.png" src="http://cl.ly/hhgttg/cover.png">}
      assert last_response.body.include?(image_tag), 'img tag not found'
    end
  end

  it 'shows a download button for a text file' do
    VCR.use_cassette 'text', :record => :none do
      get '/hhgttg'

      assert last_response.ok?, 'response not ok'
      last_response.headers['Cache-Control'].must_equal 'public, max-age=900'

      assert last_response.body.include?('<body id="download">'),
             %{<body id="download"> doesn't exist}

      refute last_response.body.include?("<img"), 'img tag found'

      heading = %{<h1 class="description left text">chapter1.txt</h1>}
      assert last_response.body.include?(heading), 'heading not found'

      link = %{<a href="http://cl.ly/hhgttg/chapter1.txt">Download</a>}
      assert last_response.body.include?(link), 'link not found'
    end
  end

  it 'forwards json response' do
    VCR.use_cassette 'text', :record => :none do
      header 'Accept', 'application/json'
      get    '/hhgttg'

      last_response.headers['Cache-Control'].must_equal 'public, max-age=900'
      last_response.headers['Content-Type'].must_equal  'application/json'

      drop = Drop.find 'hhgttg'
      last_response.body.must_equal JSON.generate(drop.data)
    end
  end

  it 'redirects the content URL to the API' do
    get '/hhgttg/chapter1.txt'

    assert last_response.redirect?
    last_response.headers['Cache-Control'].must_equal 'public, max-age=900'
    last_response.headers['Location'].
      must_equal 'http://api.cld.me/hhgttg/chapter1.txt'
  end

  it 'returns a not found response for nonexistent drops' do
    VCR.use_cassette 'nonexistent', :record => :none do
      get '/hhgttg'

      assert last_response.not_found?
    end
  end

end
