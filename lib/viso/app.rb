require 'sinatra/base'

# Viso
# ------
class Viso
  class App < Sinatra::Base

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

    # Display a `Drop` given its slug. View is cahced for 15 minutes.
    get '/:slug' do |slug|
      @drop = Viso::Drop.find slug

      cache_control :public, :max_age => 900
      erb @drop.image? ? :image : :file
    end

  end
end
