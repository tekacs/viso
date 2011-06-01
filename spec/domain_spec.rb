require 'spec_helper'
require 'support/vcr'
require 'domain'

describe Domain do

  it 'finds a domain' do
    EM.synchrony do
      VCR.use_cassette 'domain_details', :erb => { :domain => 'dent.com' } do
        domain = Domain.find 'dent.com'
        EM.stop

        assert { domain.is_a? Domain }
        assert { domain.home_page == 'http://hhgproject.org' }
      end
    end
  end

end
