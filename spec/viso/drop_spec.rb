require 'spec_helper'
require 'support/vcr'

require 'viso'

describe Viso::Drop do

  it 'finds a drop' do
    VCR.use_cassette 'image', :record => :none do
      drop = Viso::Drop.find 'hhgttg'

      assert drop.is_a?(Viso::Drop)
    end
  end

  it 'raises a DropNotFound error' do
    VCR.use_cassette 'nonexistent', :record => :none do
      lambda { Viso::Drop.find 'hhgttg' }.must_raise Viso::Drop::NotFound
    end
  end

  it 'is an image' do
    VCR.use_cassette 'image', :record => :none do
      drop = Viso::Drop.find 'hhgttg'

      assert drop.image?
    end
  end

  it 'is not an image' do
    VCR.use_cassette 'text', :record => :none do
      drop = Viso::Drop.find 'hhgttg'

      refute drop.image?
    end
  end

end
