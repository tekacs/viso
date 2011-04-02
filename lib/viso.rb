require 'json'
require 'sinatra/base'

# Viso
# ------
class Viso < Sinatra::Base

  # Load New Relic RPM in the production and staging environments.
  configure(:production, :staging) { require 'newrelic_rpm' }

  # Serve static assets from /public
  set :public, 'public'

  # Nothing to see here. Redirect to the CloudApp product page. Response is
  # cached for a year.
  get '/' do
    cache_control :public, :max_age => 31557600
    redirect 'http://getcloudapp.com'
  end

  # Use the public app's favicon. Response is cached for a year.
  get '/favicon.ico' do
    cache_control :public, :max_age => 31557600
    redirect 'http://my.cl.ly/favicon.ico'
  end

  # Forward the JSON response for a `Drop`. Response is cached for 15 minutes.
  get '/:slug', :provides => 'json' do |slug|
    drop = Drop.find slug

    cache_control :public, :max_age => 900
    content_type  :json

    JSON.generate drop.data
  end

  # Display a `Drop` given its slug. Response is cahced for 15 minutes.
  get '/:slug' do |slug|
    @drop = Drop.find slug

    cache_control :public, :max_age => 900
    erb @drop.image? ? :image : :download
  end

end
