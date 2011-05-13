require 'spec_helper'
require 'support/vcr'
require 'drop'

describe Drop do

  it 'finds a drop' do
    VCR.use_cassette 'image' do
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
    VCR.use_cassette 'nonexistent' do
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
                    :content_url => 'http://f.cl.ly/items/hhgttg/cover.png'

    refute drop.text?
  end

  it 'is text' do
    drop = Drop.new :item_type  => 'text',
                    :content_url => 'http://f.cl.ly/items/hhgttg/chapter1.txt'

    assert drop.text?
  end

  it 'is not markdown' do
    drop = Drop.new :item_type  => 'image',
                    :content_url => 'http://f.cl.ly/items/hhgttg/cover.png'

    refute drop.markdown?
  end

  it 'is markdown with the extension md' do
    drop = Drop.new :item_type  => 'unknown',
                    :content_url => 'http://f.cl.ly/items/hhgttg/chapter1.md'

    assert drop.markdown?
    assert drop.text?
  end

  it 'is markdown with the extension mdown' do
    drop = Drop.new :item_type  => 'unknown',
                    :content_url => 'http://f.cl.ly/items/hhgttg/chapter1.mdown'

    assert drop.markdown?
    assert drop.text?
  end

  it 'is markdown with the extension markdown' do
    drop = Drop.new :item_type  => 'unknown',
                    :content_url => 'http://f.cl.ly/items/hhgttg/chapter1.markdown'

    assert drop.markdown?
    assert drop.text?
  end

  it 'has content' do
    VCR.use_cassette 'text' do
      drop = Drop.new :item_type  => 'text',
                      :content_url => 'http://f.cl.ly/items/hhgttg/chapter1.txt'

      assert drop.content.start_with?('Chapter 1')
    end
  end

  it "doesn't have content" do
    drop = Drop.new :item_type  => 'image',
                    :content_url => 'http://f.cl.ly/items/hhgttg/cover.png'

    assert drop.content.nil?
  end

  it 'parses markdown content' do
    VCR.use_cassette 'markdown' do
      drop = Drop.new :item_type  => 'unknown',
                      :content_url => 'http://f.cl.ly/items/hhgttg/chapter1.md'


      assert drop.content.start_with?('<h1>Chapter 1</h1>')
    end
  end

end
