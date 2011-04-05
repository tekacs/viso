# Viso
# ------
#
# **Viso** is a simple Sinatra app that displays CloudApp Drops. Images are
# displayed front and center, bookmarks are redirected to their destination, and
# a download button is provided for all other file types.
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

  before { headers['Vary'] = 'Accept' }

  # The home page. Nothing to see here. Redirect to the CloudApp product page.
  # Response is cached for one year.
  get '/' do
    cache_control :public, :max_age => 31557600
    redirect 'http://getcloudapp.com'
  end

  # Redirect to the public app's favicon. Response is cached for one year.
  get '/favicon.ico' do
    cache_control :public, :max_age => 31557600
    redirect 'http://my.cl.ly/favicon.ico'
  end

  # Handle a JSON request for a **Drop**. Return the same data received from the
  # CloudApp API. Response is cached for 15 minutes.
  get '/:slug', :provides => 'json' do |slug|
    drop = find_drop slug

    cache_control :public, :max_age => 900
    content_type  :json

    JSON.generate drop.data
  end

  # The main responder for a **Drop**. Redirect to the bookmark's link, render
  # the image view for an image, or render the generic download view for
  # everything else. Response is cached for 15 minutes.
  get '/:slug' do |slug|
    @drop = find_drop slug
    cache_control :public, :max_age => 900

    if @drop.bookmark?
      redirect_to_api
    else
      erb @drop.image? ? :image : :download
    end
  end

  # The content for a **Drop**. Redirect to the identical path on the API domain
  # where the view counter is incremented and the visitor is redirected to the
  # actual URL of file. Response is cached for 15 minutes.
  get '/:slug/:filename' do |slug, filename|
    cache_control :public, :max_age => 900
    redirect_to_api
  end

protected

  # Find and return a **Drop** with the given `slug`. Handle `Drop::NotFound`
  # errors and render the not found response.
  def find_drop(slug)
    Drop.find slug
  rescue Drop::NotFound
    not_found
  end

  # Redirect the current request to the same path on the API domain.
  def redirect_to_api
    redirect "#{ Drop.base_uri }#{ request.path }"
  end

end
