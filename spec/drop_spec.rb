require 'spec_helper'
require 'support/vcr'
require 'drop'

describe Drop do

  it 'finds a drop' do
    VCR.use_cassette 'image', :record => :none do
      drop = Drop.find 'hhgttg'

      assert drop.is_a?(Drop)
    end
  end

  it 'returns a hash of itself' do
    data = { :name => 'The Guide' }
    drop = Drop.new data

    drop.data.must_equal data
  end

  it 'raises a DropNotFound error' do
    VCR.use_cassette 'nonexistent', :record => :none do
      lambda { Drop.find 'hhgttg' }.must_raise Drop::NotFound
    end
  end

  it 'is not an image' do
    drop = Drop.new :item_type => 'text'

    refute drop.image?
  end

  it 'is an image' do
    drop = Drop.new :item_type => 'image'

    assert drop.image?
  end

  it 'is not a bookmark' do
    drop = Drop.new :item_type => 'text'

    refute drop.bookmark?
  end

  it 'is a bookmark' do
    drop = Drop.new :item_type => 'bookmark'

    assert drop.bookmark?
  end

  it 'is not text' do
    drop = Drop.new :item_type  => 'image',
                    :remote_url => 'http://f.cl.ly/items/hhgttg/cover.png'

    refute drop.text?
  end

  it 'is text' do
    drop = Drop.new :item_type  => 'text',
                    :remote_url => 'http://f.cl.ly/items/hhgttg/chapter1.txt'

    assert drop.text?
  end

  #it 'a code file is text' do
    #drop = Drop.new :item_type  => 'ruby',
                    #:remote_url => 'http://f.cl.ly/items/hhgttg/code.rb'

    #assert drop.text?
  #end

end
