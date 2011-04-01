(function($) {
  $(function() {
    var viewport     = $(window),
        body         = $("body"),
        header       = $("#navbar"),
        image        = $("img"),
        imagePadding = 50,
        fullWidth    = 0,
        fullHeight   = 0,

        imageDelegate = {
          load: function() {
            if (image.data("initialized")) { return; }
            image.data("initialized", true);

            fullWidth  = this.width;
            fullHeight = this.height;

            image
              .addClass("loaded center")
              .trigger("resize");
          },

          click: function() {
            image.trigger("zoom");
          },

          resize: function() {
            var maxWidth  = viewport.width()  - imagePadding,
                maxHeight = viewport.height() - imagePadding;

            if (body.is(".zoom")) { return; }

            if (fullWidth > maxWidth || fullHeight > maxHeight) {
              image
                .addClass("zoom_in")
                .css({ maxWidth: maxWidth, maxHeight: maxHeight });
            } else {
              image
                .removeClass("zoom_in")
                .css({ maxWidth: '', maxHeight: '' });
            }

            image.trigger("center");
          },

          center: function() {
            var left = Math.round(this.width  / -2),
                top  = Math.round(this.height / -2);

            image.css({ marginLeft: left, marginTop: top });
          },

          zoom: function() {
            if (body.is(".zoom")) {
              body.removeClass("zoom");
              image
                .addClass("center")
                .removeClass("zoom_out")
                .trigger("resize");

              return;
            }

            // Image not zoomable
            if (!image.is(".zoom_in")) { return; }

            body.addClass("zoom");
            image
              .removeClass("center")
              .addClass("zoom_out")
              .css({
                maxWidth:   '',
                maxHeight:  '',
                marginLeft: '',
                marginTop:  ''
              });
          }
        },

        headerDelegate = {
          show: function() {
            if (header.data("shown")) { return; }

            header
              .data("shown", true)
              .stop(true)
              .animate({ opacity: 0.9 }, 250);
          },

          hide: function() {
            header
              .removeData("shown")
              .animate({ opacity: 0 }, 250);
          }
        },

        viewportDelegate = {
          resize: function() {
            image.trigger("resize");
            $(document).trigger("mousemove");
          },

          mousemove: function(e) {
            header.trigger("show");

            if (viewport.data("mouseMoveTimeout")) {
              window.clearTimeout(viewport.data("mouseMoveTimeout"));
            }

            if (viewport.data("mouseOutTimeout")) {
              window.clearTimeout(viewport.data("mouseOutTimeout"));
            }

            // Don't hide the header if the mouse is inside it.
            if (e.clientY < 40) { return; }

            viewport.data("mouseMoveTimeout",
              window.setTimeout(function() {
                header.trigger("hide");
              }, 1000));
          },

          mouseout: function(e) {
            viewport.data("mouseOutTimeout",
              window.setTimeout(function() {
                header.trigger("hide");
              }, 10));
          }
        };


    image.hotwire(imageDelegate, "load", "click", "resize", "center", "zoom");

    // Make sure the load event fires even if the image is cached.
    if (image[0].complete) {
      image.trigger("load");
    }

    header.hotwire(headerDelegate, "show", "hide");
    viewport.hotwire(viewportDelegate, "resize");

    $(document)
      .hotwire(viewportDelegate, "mousemove", "mouseout")
      .trigger("mousemove");

    body.addClass("js");
  });
}(jQuery));
