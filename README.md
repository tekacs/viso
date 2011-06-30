# Viso

Viso powers all public CloudApp pages. It [displays images][image],
[redirects bookmarks][bookmark] to their URL, and provides a
[download button][download] for all other file types. It's a thin client that at
its heart is a simple [Sinatra] app which handles drop requests, pings the
[CloudApp API] for its details, and renders or redirects according to the type
of drop.

The power of Viso lies in its ability to be fully personalized. Don't like the
default CloudApp image viewer? Tired of waiting for an HTML5 video player? No
more! Fork the project, hack away, and deploy. That's all there is to it.


[image]:        http://cl.ly/2wr4
[bookmark]:     http://cl.ly/2wt6
[download]:     http://cl.ly/5muk
[sinatra]:      https://github.com/sinatra/sinatra
[cloudapp api]: http://developer.getcloudapp.com/view-item


## Prerequisites

Viso's needs are basic: Ruby 1.9.2 and [Bundler]. Using [RVM] is highly
recommended but not required. Assuming RVM is installed, getting up and running
with Ruby 1.9.2 is as simple as:

    rvm install 1.9.2

After Ruby has compiled, clone the project and create a stub [rvmrc].

    git clone git@github.com:cloudapp/viso.git
    cd viso
    rvm use 1.9.2 --rvmrc


[rvm]:     http://rvm.beginrescueend.com
[rvmrc]:   http://rvm.beginrescueend.com/workflow/rvmrc/
[bundler]: https://github.com/carlhuda/bundler


## Getting Started

Viso uses Bundler to manage its dependencies. Install everything and kick start
`shotgun` to run Viso locally.

    gem install bundler
    bundle install
    bundle exec shotgun

Browse to <http://localhost:9393>. If you're redirected to
<http://getcloudapp.com>, it's alive! Now grab one of your drops and replace the
"cl.ly" domain with "localhost:9393" and watch the magic happen. Or, if you're
lazy, just [click here](http://localhost:9393/2wr4).


## Working

Crack open the [image viewer] to start hacking some markup and the [stylesheet]
to get to stylin'. Of course, seeing as how this is _your_ CloudApp, you're free
to completely destroy everything and rebuild from the ground up. Have at it.


[image viewer]: https://github.com/cloudapp/viso/blob/master/views/image.erb
[stylesheet]:   https://github.com/cloudapp/viso/blob/master/public/stylesheets/old/slugs.css


## Parting Words

We'd love to see what you're doing with Viso. [Get a hold of us][twitter] and
show it off! Did you find something broken? [Open an issue][issue] or send over
a pull request.


[twitter]: http://twitter.com/cloudapp
[issue]:   https://github.com/cloudapp/viso/issues


## License

Viso is released under the MIT license.
