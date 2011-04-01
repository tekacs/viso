require 'spec_helper'
require 'rack/test'
require 'support/vcr'

require 'viso'
require 'viso/app'

describe Viso::App do

  include Rack::Test::Methods

  def app
    Viso::App
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

      assert last_response.body.include?('<body id="image">'),
             %{<body id="image"> doesn't exist}

      image_tag = %{<img alt="cover.png" src="http://f.cl.ly/items/hhgttg/cover.png">}
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
    end
  end

end
