require 'helper'
require 'support/vcr'
require 'drop'

describe Drop do

  def self.subject(&block)
    define_method :subject, &block
  end


  it 'returns a hash of itself' do
    data = { :name => 'The Guide' }
    drop = Drop.new data

    assert { drop.data == data }
  end


  describe 'a bookmark' do
    subject do
      Drop.new :item_type => 'bookmark'
    end

    it 'is a bookmark' do
      assert { subject.bookmark? }
    end

    %w( code image markdown plain_text text ).each do |type|
      it "is not a #{ type }" do
        deny { subject.send("#{ type }?") }
      end
    end
  end

  describe 'an image' do
    subject do
      Drop.new :item_type   => 'image',
               :content_url => 'http://cl.ly/hhgttg/cover.png'
    end

    it 'is an image' do
      assert { subject.image? }
    end

    %w( bookmark code markdown plain_text text ).each do |type|
      it "is not a #{ type }" do
        deny { subject.send("#{ type }?") }
      end
    end

    it "doesn't have content" do
      assert { subject.content.nil? }
    end
  end

  describe 'a text file' do
    subject do
      Drop.new :item_type   => 'text',
               :content_url => 'http://cl.ly/hhgttg/chapter1.txt'
    end

    it 'is plain text' do
      assert { subject.plain_text? }
    end

    it 'is text' do
      assert { subject.text? }
    end

    %w( bookmark code image markdown ).each do |type|
      it "is not a #{ type }" do
        deny { subject.send("#{ type }?") }
      end
    end

    it 'fetches the content' do
      EM.synchrony do
        VCR.use_cassette 'text' do
          assert { subject.content.start_with? 'Chapter 1' }

          EM.stop
        end
      end
    end
  end

  %w( md mdown markdown ).each do |markdown_extension|

    describe "a markdown file with the extension #{ markdown_extension }" do
      subject do
        Drop.new :item_type   => 'unknown',
                 :content_url => "http://cl.ly/hhgttg/chapter1.#{ markdown_extension }"
      end

      it 'is markdown' do
        assert { subject.markdown? }
      end

      it 'is text' do
        assert { subject.text? }
      end

      %w( bookmark code image plain_text ).each do |type|
        it "is not a #{ type }" do
          deny { subject.send("#{ type }?") }
        end
      end
    end

  end

  describe 'a markdown file' do
    subject do
      Drop.new :item_type   => 'unknown',
               :content_url => 'http://cl.ly/hhgttg/chapter1.md'
    end

    it 'fetches and parses the content' do
      EM.synchrony do
        VCR.use_cassette 'markdown' do
          assert { subject.content.start_with? '<h1>Chapter 1</h1>' }

          EM.stop
        end
      end
    end
  end

  describe 'a code file' do
    subject do
      Drop.new :item_type   => 'unknown',
               :content_url => 'http://cl.ly/hhgttg/hello.rb'
    end

    it 'is code' do
      assert { subject.code? }
    end

    it 'is text' do
      assert { subject.text? }
    end

    %w( bookmark image markdown plain_text ).each do |type|
      it "is not a #{ type }" do
        deny { subject.send("#{ type }?") }
      end
    end

    it 'fetches and highlights the content' do
      EM.synchrony do
        VCR.use_cassette 'ruby' do
          highlighted = '<div class="highlight"><pre><span class="nb">puts</span>'
          assert { subject.content.start_with? highlighted }

          EM.stop
        end
      end
    end
  end


  describe 'an rtf file' do
    subject do
      Drop.new :item_type   => 'text',
               :content_url => 'http://cl.ly/hhgttg/chapter1.rtf'
    end

    %w( bookmark code image markdown plain_text text ).each do |type|
      it "is not a #{ type }" do
        deny { subject.send("#{ type }?") }
      end
    end
  end

  describe 'a postscript file' do
    subject do
      Drop.new :item_type   => 'unknown',
               :content_url => 'http://cl.ly/hhgttg/chapter1.ps'
    end

    %w( bookmark code image markdown plain_text text ).each do |type|
      it "is not a #{ type }" do
        deny { subject.send("#{ type }?") }
      end
    end
  end

  describe 'subscribed' do
    subject { Drop.new :subscribed => true }

    it 'is subscribed' do
      assert { subject.subscribed? }
    end
  end

  describe 'unsubscribed' do
    subject { Drop.new :subscribed => false }

    it 'is not subscribed' do
      deny { subject.subscribed? }
    end
  end


  describe 'finding' do
    it 'finds a bookmark' do
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
  end

end
