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

    assert last_response.redirect?, 'response not a redirect'
    last_response.headers['Cache-Control'].must_equal 'public, max-age=31557600'
    last_response.headers['Vary'].must_equal          'Accept'
    last_response.headers['Location'].must_equal 'http://getcloudapp.com'
  end

  it 'redirects the favicon to the CloudApp favicon' do
    get '/favicon.ico'

    assert last_response.redirect?, 'response not a redirect'
    last_response.headers['Cache-Control'].must_equal 'public, max-age=31557600'
    last_response.headers['Vary'].must_equal          'Accept'
    last_response.headers['Location'].must_equal 'http://my.cl.ly/favicon.ico'
  end

  it 'displays an image drop' do
    VCR.use_cassette 'image' do
      get '/hhgttg'

      assert last_response.ok?, 'response not ok'
      last_response.headers['Cache-Control'].must_equal 'public, max-age=900'
      last_response.headers['Vary'].must_equal          'Accept'

      image_tag = %{<img alt="cover.png" src="http://cl.ly/hhgttg/cover.png">}
      assert last_response.body.include?(image_tag), 'img tag not found'
    end
  end

  it 'shows a download button for a text file' do
    VCR.use_cassette 'text' do
      get '/hhgttg'

      assert last_response.ok?, 'response not ok'
      last_response.headers['Cache-Control'].must_equal 'public, max-age=900'
      last_response.headers['Vary'].must_equal          'Accept'

      assert last_response.body.include?('<body id="other">'),
             %{<body id="download"> doesn't exist}

      refute last_response.body.include?("<img"), 'img tag found'

      heading = %{<h1 class="description left text">chapter1.txt</h1>}
      assert last_response.body.include?(heading), 'heading not found'

      link = %{<a href="http://cl.ly/hhgttg/chapter1.txt">Download</a>}
      assert last_response.body.include?(link), 'link not found'
    end
  end

  it 'forwards json response' do
    VCR.use_cassette 'text' do
      header 'Accept', 'application/json'
      get    '/hhgttg'

      last_response.headers['Cache-Control'].must_equal 'public, max-age=900'
      last_response.headers['Vary'].must_equal          'Accept'
      last_response.headers['Content-Type'].must_equal  'application/json'

      drop = Drop.find 'hhgttg'
      last_response.body.must_equal JSON.generate(drop.data)
    end
  end

  it 'redirects the content URL to the API' do
    get '/hhgttg/chapter1.txt'

    assert last_response.redirect?, 'response not a redirect'
    last_response.headers['Cache-Control'].must_equal 'public, max-age=900'
    last_response.headers['Vary'].must_equal          'Accept'
    last_response.headers['Location'].
      must_equal 'http://api.cld.me/hhgttg/chapter1.txt'
  end

  it 'returns a not found response for nonexistent drops' do
    VCR.use_cassette 'nonexistent' do
      get '/hhgttg'

      assert last_response.not_found?, 'response was found'
      last_response.body.must_equal    '<h1>Not Found</h1>'
    end
  end

  it 'redirects a bookmark to the API' do
    VCR.use_cassette 'bookmark' do
      get '/hhgttg'

      assert last_response.redirect?, 'response not a redirect'
      last_response.headers['Cache-Control'].must_equal 'public, max-age=900'
      last_response.headers['Vary'].must_equal          'Accept'
      last_response.headers['Location'].must_equal 'http://api.cld.me/hhgttg'
    end
  end

  it "redirects a bookmark's content URL to the API" do
    VCR.use_cassette 'bookmark' do
      get '/hhgttg/content'

      assert last_response.redirect?, 'response not a redirect'
      last_response.headers['Cache-Control'].must_equal 'public, max-age=900'
      last_response.headers['Vary'].must_equal          'Accept'
      last_response.headers['Location'].
        must_equal 'http://api.cld.me/hhgttg/content'
    end
  end

  it 'respects accept header priority' do
    VCR.use_cassette 'text' do
      header 'Accept', 'text/html,application/json'
      get    '/hhgttg'

      last_response.headers['Content-Type'].must_equal 'text/html;charset=utf-8'
    end
  end

  it 'serves html by default' do
    VCR.use_cassette 'text' do
      header 'Accept', '*/*'
      get    '/hhgttg'

      last_response.headers['Content-Type'].must_equal 'text/html;charset=utf-8'
    end
  end

end
