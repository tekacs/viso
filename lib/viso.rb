# Viso
# ------
#
# **Viso** is the magic that powers [CloudApp][] by displaying shared Drops. At
# its core, **Viso** is a simple [Sinatra][] app that retrieves a **Drop's**
# details using the [CloudApp API][]. Images are displayed front and center,
# bookmarks are redirected to their destination, markdown is processed by
# [RedCarpet][], code files are highlighted by [Pygments], and, when all else
# fails, a download button is provided. **Viso** uses [eventmachine][] and
# [rack-fiber_pool][] to serve requests while expensive network I/O is performed
# asynchronously.
#
# [cloudapp]:        http://getcloudapp.com
# [sinatra]:         https://github.com/sinatra/sinatra
# [cloudapp api]:    http://developer.getcloudapp.com
# [redcarpet]:       https://github.com/tanoku/redcarpet
# [pygments]:        http://pygments.org
# [eventmachine]:    https://github.com/eventmachine/eventmachine
# [rack-fiber_pool]: https://github.com/mperham/rack-fiber_pool
require 'eventmachine'
require 'sinatra/base'
require 'sinatra/respond_with'
require 'yajl'

require_relative 'jammit_helper'
require_relative 'drop'
require_relative 'domain'

class Viso < Sinatra::Base

  # Make use of `respond_to` to handle content negotiation.
  register Sinatra::RespondWith
  register JammitHelper

  # Load New Relic RPM and Hoptoad in the production and staging environments.
  # Add your Hoptoad API key to the environment variable `HOPTOAD_API_KEY` and
  # Hoptoad will catalog your exceptions. Explicitly require some bits from
  # `activesupport` that Hoptoad needs.
  configure :production do
    require 'newrelic_rpm'
    require_relative 'newrelic_instrumentation'

    if ENV['HOPTOAD_API_KEY']
      require 'active_support'
      require 'active_support/core_ext/object/blank'
      require 'hoptoad_notifier'

      HoptoadNotifier.configure do |config|
        config.api_key = ENV['HOPTOAD_API_KEY']
      end

      use HoptoadNotifier::Rack
      enable :raise_errors
    end
  end

  configure :development do
    require 'new_relic/control'
    NewRelic::Control.instance.init_plugin 'developer_mode' => true,
      :env => 'development'

    require 'new_relic/rack/developer_mode'
    use NewRelic::Rack::DeveloperMode

    require_relative 'newrelic_instrumentation'
  end

  # Use a fiber pool to serve **Viso** when outside of the test environment.
  configure do
    unless test?
      require 'rack/fiber_pool'
      use Rack::FiberPool
    end
  end

  # Serve static assets from `/public`
  set :public, 'public'

  # Bring in some helper methods from Rack to aid in escaping HTML.
  helpers { include Rack::Utils }

  # Cached responses are only valid for a specific accept header.
  before { headers['Vary'] = 'Accept' }

  # The home page. Custom domain users have the option to set a home page so
  # ping the API to get the home page for the current domain. Response is cached
  # for one hour.
  get '/' do
    cache_control :public, :max_age => 3600
    redirect Domain.find(env['HTTP_HOST']).home_page
  end

  # The main responder for a **Drop**. Responds to both JSON and HTML and
  # response is cached for 15 minutes.
  get %r{^
        /
          ([^/?#]+)  # Item slug
          (?:
            /  |     # Ignore trailing /
            /o       # Show original image size
          )?
      $}x do |slug|
    begin
      @drop = find_drop slug
      cache_control :public, :max_age => 900

      respond_to do |format|

        # Redirect to the bookmark's link, render the image view for an image, or
        # render the generic download view for everything else.
        format.html do
          if @drop.bookmark?
            redirect_to_api
          else
            erb drop_template, :locals => { :body_id => body_id }
          end
        end

        # Handle a JSON request for a **Drop**. Return the same data received from
        # the CloudApp API.
        format.json do
          Yajl::Encoder.encode @drop.data
        end
      end
    rescue => e
      env['async.callback'].call [ 500, {}, 'Internal Server Error' ]
      HoptoadNotifier.notify_or_ignore e if defined? HoptoadNotifier
    end
  end

  # The content for a **Drop**. Redirect to the identical path on the API domain
  # where the view counter is incremented and the visitor is redirected to the
  # actual URL of file. Response is cached for 15 minutes.
  get '/:slug/:filename' do |slug, filename|
    cache_control :public, :max_age => 900
    redirect_to_api
  end

  # Don't need to return anything special for a 404.
  not_found do
    not_found '<h1>Not Found</h1>'
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
    redirect "http://#{ Drop.base_uri }#{ request.path }"
  end

  def drop_template
    if @drop.image?
      :image
    elsif @drop.text?
      :text
    else
      :other
    end
  end

  def body_id
    if @drop.image?
      'image'
    elsif @drop.text?
      'text'
    else
      'other'
    end
  end

end
