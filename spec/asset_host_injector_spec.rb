require 'helper'
require 'jammit_helper'
require 'ostruct'

describe JammitHelper::AssetHostInjector do
  class App
    include JammitHelper::AssetHostInjector

    def initialize(options = {})
      @ssl = options.fetch :ssl, false
    end

    def request
      OpenStruct.new :ssl? => @ssl
    end

    def self.development?
      false
    end
  end

  before { ENV['CLOUDFRONT_DOMAIN'] = 'fake.cloudfront.net' }
  after do
    %w( CLOUDFRONT_DOMAIN CLOUDFRONT_CNAME ).each do |key|
      ENV.delete key
    end
  end

  subject do
    Jammit.load_configuration 'config/assets.yml'
    App.new
  end

  it 'serves assets on the cloudfront domain' do
    asset_path = subject.asset_path :js, 'app.js'

    assert { asset_path == 'http://fake.cloudfront.net/app.js' }
  end

  it 'serves assets using a cloudfront cname' do
    ENV['CLOUDFRONT_CNAME'] = 'assets.theguide.com'
    asset_path = subject.asset_path :js, 'app.js'

    assert { asset_path == 'http://assets.theguide.com/app.js' }
  end

end
