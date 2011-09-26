# Adapted from https://github.com/railsjedi/jammit-sinatra

# jammit/helper assumes ActionView is present
module ActionView
  class Base
  end
end

require 'jammit'
require 'jammit/helper'
require 'padrino-helpers'

module JammitHelper
  def self.registered(app)
    Jammit.load_configuration 'config/assets.yml'

    app.helpers Padrino::Helpers
    app.helpers Jammit::Helper

    # Reload assets and prevent packaging on every request in development mode.
    if app.development?
      app.before do
        Jammit.reload!
        Jammit.set_package_assets false
      end
    end
  end
end
