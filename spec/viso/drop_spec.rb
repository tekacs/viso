require 'spec_helper'
require 'support/vcr'

require 'viso'

describe Viso::Drop do

  it 'raises a DropNotFound error' do
    VCR.use_cassette 'nonexistent', :record => :none do
      lambda { Viso::Drop.find 'hhgttg' }.must_raise Viso::Drop::NotFound
    end
  end

end
