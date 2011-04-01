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
    last_response.headers['Location'].must_equal      'http://getcloudapp.com'
    last_response.headers['Cache-Control'].must_equal 'public, max-age=31557600'
  end

  it 'redirects the favicon to the CloudApp favicon' do
    get '/favicon.ico'

    assert last_response.redirect?
    last_response.headers['Location'].must_equal      'http://my.cl.ly/favicon.ico'
    last_response.headers['Cache-Control'].must_equal 'public, max-age=31557600'
  end

end
