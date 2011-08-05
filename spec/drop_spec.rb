require 'helper'
require 'support/vcr'
require 'drop'

describe Drop do

  it 'returns a hash of itself' do
    data = { :name => 'The Guide' }
    drop = Drop.new data

    assert { drop.data == data }
  end


  # Drop types

  it 'is not an image when text' do
    drop = Drop.new :item_type => 'text'

    deny { drop.image? }
  end

  it 'is an image' do
    drop = Drop.new :item_type => 'image'

    assert { drop.image? }
  end


  it 'is not a bookmark when text' do
    drop = Drop.new :item_type => 'text'

    deny { drop.bookmark? }
  end

  it 'is a bookmark' do
    drop = Drop.new :item_type => 'bookmark'

    assert { drop.bookmark? }
  end


  it 'is not text when an image' do
    drop = Drop.new :item_type   => 'image',
                    :content_url => 'http://f.cl.ly/items/hhgttg/cover.png'

    deny { drop.text? }
  end

  it 'is not text when rtf' do
    drop = Drop.new :item_type   => 'text',
                    :content_url => 'http://f.cl.ly/items/hhgttg/chapter1.rtf'

    deny { drop.text? }
  end

  it 'is not text when markdown' do
    drop = Drop.new :content_url => 'http://f.cl.ly/items/hhgttg/chapter1.md'

    deny { drop.text? }
  end

  it 'is text' do
    drop = Drop.new :item_type   => 'text',
                    :content_url => 'http://f.cl.ly/items/hhgttg/chapter1.txt'

    assert { drop.text? }
  end


  it 'is not markdown when an image' do
    drop = Drop.new :item_type   => 'image',
                    :content_url => 'http://f.cl.ly/items/hhgttg/cover.png'

    deny { drop.markdown? }
  end

  it 'is not markdown when text' do
    drop = Drop.new :item_type   => 'text',
                    :content_url => 'http://f.cl.ly/items/hhgttg/chapter1.txt'

    deny { drop.markdown? }
  end

  it 'is markdown with the extension md' do
    drop = Drop.new :content_url => 'http://f.cl.ly/items/hhgttg/chapter1.md'

    assert { drop.markdown? }
  end

  it 'is markdown with the extension mdown' do
    drop = Drop.new :content_url => 'http://f.cl.ly/items/hhgttg/chapter1.mdown'

    assert { drop.markdown? }
  end

  it 'is markdown with the extension markdown' do
    drop = Drop.new :content_url => 'http://f.cl.ly/items/hhgttg/chapter1.markdown'

    assert { drop.markdown? }
  end


  it 'is not code when an image' do
    drop = Drop.new :item_type   => 'image',
                    :content_url => 'http://f.cl.ly/items/hhgttg/cover.png'

    deny { drop.code? }
  end

  it 'is not code when text' do
    drop = Drop.new :item_type   => 'text',
                    :content_url => 'http://f.cl.ly/items/hhgttg/chapter1.txt'

    deny { drop.code? }
  end

  it 'is code with the extension rb' do
    drop = Drop.new :item_type   => 'unknown',
                    :content_url => 'http://f.cl.ly/items/hhgttg/code.rb'

    assert { drop.code? }
  end


  it 'is not subscribed when not subscribed' do
    drop = Drop.new :subscribed => false

    deny { drop.subscribed? }
  end

  it 'is subscribed when subscribed' do
    drop = Drop.new :subscribed => true

    assert { drop.subscribed? }
  end


  # Find a drop

  it 'finds a drop' do
    EM.synchrony do
      VCR.use_cassette 'bookmark' do
        drop = Drop.find 'hhgttg'
        EM.stop

        assert { drop.is_a? Drop }
        assert { drop.href         == 'http://my.cl.ly/items/4268562' }
        assert { drop.redirect_url == 'http://getcloudapp.com/download' }
        assert { drop.remote_url.nil? }
      end
    end
  end

  it 'finds an image' do
    EM.synchrony do
      VCR.use_cassette 'image' do
        drop = Drop.find 'hhgttg'
        EM.stop

        assert { drop.is_a? Drop }
        assert { drop.href       == 'http://my.cl.ly/items/307' }
        assert { drop.remote_url == 'http://f.cl.ly/items/hhgttg/cover.png'}
        assert { drop.redirect_url.nil? }
      end
    end
  end

  it 'raises a DropNotFound error' do
    EM.synchrony do
      VCR.use_cassette 'nonexistent' do
        assert { rescuing { Drop.find('hhgttg') }.is_a? Drop::NotFound }

        EM.stop
      end
    end
  end


  # Fetch drop content

  it "doesn't have content" do
    drop = Drop.new :item_type   => 'image',
                    :content_url => 'http://f.cl.ly/items/hhgttg/cover.png'

    assert { drop.content.nil? }
  end

  it 'fetches the content of a text file' do
    EM.synchrony do
      VCR.use_cassette 'text' do
        drop = Drop.new :item_type   => 'text',
                        :content_url => 'http://cl.ly/hhgttg/chapter1.txt'

        assert { drop.content.start_with? 'Chapter 1' }

        EM.stop
      end
    end
  end

  it 'fetches and parses the content of a markdown file' do
    EM.synchrony do
      VCR.use_cassette 'markdown' do
        drop = Drop.new :item_type   => 'unknown',
                        :content_url => 'http://cl.ly/hhgttg/chapter1.md'


        assert { drop.content.start_with? '<h1>Chapter 1</h1>' }

        EM.stop
      end
    end
  end

  it 'fetches and highlights the syntax of a code file' do
    EM.synchrony do
      VCR.use_cassette 'ruby' do
        drop = Drop.new :item_type   => 'unknown',
                        :content_url => 'http://cl.ly/hhgttg/hello.rb'


        highlighted = '<div class="highlight"><pre><span class="nb">puts</span>'
        assert { drop.content.start_with? highlighted }

        EM.stop
      end
    end
  end

end
