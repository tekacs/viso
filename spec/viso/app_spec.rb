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

  it "redirects to a drop's remote url" do
    VCR.use_cassette 'image', :record => :none do
      get '/hhgttg'

      assert last_response.ok?
      last_response.headers['Cache-Control'].must_equal 'public, max-age=900'

      image_tag = %{<img alt="cover.png" src="http://f.cl.ly/items/hhgttg/cover.png">}
      assert last_response.body.include?(image_tag), 'Image tag not found'
    end
  end

end
