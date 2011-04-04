# Viso
# ------
#
# **Viso** is a simple Sinatra app that displays CloudApp Drops. Images are
# displayed front and center while a download button is provided for other file
# types.
require_relative 'drop'
require 'json'
require 'sinatra/base'

class Viso < Sinatra::Base

  # Load New Relic RPM in the production and staging environments.
  configure(:production, :staging) { require 'newrelic_rpm' }

  # Serve static assets from `/public`
  set :public, 'public'

  # Bring in some helper methods from Rack to aid in escaping HTML.
  helpers { include Rack::Utils }

  # The home page. Nothing to see here. Redirect to the CloudApp product page.
  # Response is cached for a year.
  get '/' do
    cache_control :public, :max_age => 31557600
    redirect 'http://getcloudapp.com'
  end

  # Use the public app's favicon. Response is cached for a year.
  get '/favicon.ico' do
    cache_control :public, :max_age => 31557600
    redirect 'http://my.cl.ly/favicon.ico'
  end

  # JSON request for a **Drop**. Return the same data received from the CloudApp
  # API. Response is cached for 15 minutes.
  get '/:slug', :provides => 'json' do |slug|
    drop = Drop.find slug

    cache_control :public, :max_age => 900
    content_type  :json

    JSON.generate drop.data
  end

  # All other non-JSON requests for a **Drop**. Render the image view for images
  # and the download view for everything else.
  get '/:slug' do |slug|
    @drop = Drop.find slug

    cache_control :public, :max_age => 900
    erb @drop.image? ? :image : :download
  end

  get '/:slug/:filename' do |slug, filename|
    cache_control :public, :max_age => 900
    redirect "#{ Drop.base_uri }#{ request.path }"
  end

end
