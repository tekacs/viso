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

  it 'returns a hash of itself' do
    data = { :name => 'The Guide' }
    drop = Viso::Drop.new data

    drop.data.must_equal data
  end

  it 'raises a DropNotFound error' do
    VCR.use_cassette 'nonexistent', :record => :none do
      lambda { Viso::Drop.find 'hhgttg' }.must_raise Viso::Drop::NotFound
    end
  end

  it 'is an image' do
    drop = Viso::Drop.new :item_type => 'image'

    assert drop.image?
  end

  it 'is not an image' do
    drop = Viso::Drop.new :item_type => 'text'

    refute drop.image?
  end

end
