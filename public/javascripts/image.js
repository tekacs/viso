(function($) {
  $(function() {
    var hasPushState = (typeof history.pushState !== 'undefined'),
        viewport     = $(window),
        body         = $("body"),
        content      = $("#content"),
        image        = $("img"),
        headerHeight = $("h2").height(),
        imagePadding = (image.position().top - headerHeight) * 2 + headerHeight,
        full         = { height: 0, width: 0 },
        max          = { height: 0, width: 0 };


    // Calculate the maximum width and height of the viewport when it is
    // resized. Add `max-height` to the image so it fits comfortably within the
    // viewable area and trigger `"zoom"` on the image.
    viewport
      .resize(function() {
        max.width  = Math.floor(viewport.width()  * 0.9);
        max.height = viewport.height() - imagePadding;

        if (!body.is(".zoomed-in")) {
          image
            .css({ maxHeight: max.height })
            .trigger("zoom");
        } else {
          image.trigger("center");
        }
      })

      .bind("popstate", function() {
        if (location.pathname.match(/.+\/o$/)) {
          image.trigger("zoom-in");
        } else {
          image.trigger("zoom-out");
        }
      });

    image

      // Check the current maximum image dimensions and add the class
      // `"zoomed-out"` if the image is too large to fit otherwise remove it.
      // Trigger `"center"` to center the image vertically.
      .bind("zoom", function() {
        // Ignore image resizing when the image is zoomed in.
        if (body.is(".zoomed-in")) { return; }

        // Only attempt to zoom if the image has been initialized.
        if (!image.data("initialized")) { return; }

        if (full.width > max.width || full.height > max.height) {
          body.addClass("zoomed-out");
        } else {
          body.removeClass("zoomed-out");
        }

        image.trigger("center");
      })

      // Zoom the image in and center it.
      .bind("zoom-in", function() {
        body
          .addClass("zoomed-in")
          .removeClass("zoomed-out");

        image.trigger("center");
      })

      // Zoom the image out.
      .bind("zoom-out", function() {
        body.removeClass("zoomed-in");
        viewport.trigger("resize");
      })

      // Center the image vertically in the viewport leaving room for the
      // header. Ignore attempts to center the image if it has yet to be
      // initialized.
      .bind("center", function() {
        if (!image.data("initialized")) { return; }

        var viewportSize = viewport.height() - image.height();
        if (body.is(".zoomed-out")) {
          viewportSize -= headerHeight;
        } else {
          // Account for padding around the image when zoomed in.
          viewportSize -= 36;
        }

        var top = Math.floor(viewportSize / 2);
        content.css({ paddingTop: top });
      })

      // Handle clicks on the image to toggle its zoom by toggling the path
      // suffix `/o` if the browser supports pushState. Do nothing unless the
      // image is zoomed in or out.
      .click(function() {
        if (body.is(".zoomed-in")) {
          if (hasPushState) {
            var path = location.pathname.match(/(.+)\/o$/)[1];
            history.pushState(null, null, path);
          }

          image.trigger("zoom-out");
        } else if (body.is(".zoomed-out")) {
          if (hasPushState) {
            var path = location.pathname + "/o";
            history.pushState(null, null, path);
          }

          image.trigger("zoom-in");
        }
      });


    // Create a temporary image to determine the full size of the main image and
    // trigger `"resize"` on the image.
    var tmpImage = $("<img/>")
                     .attr("src", image.attr("src"))
                     .load(function() {
                       full.width   = this.width;
                       full.height  = this.height;

                       image
                         .data("initialized", true)
                         .trigger("zoom")
                         .trigger("center");
                     });

    // Make sure the load event fires even if the image is cached.
    if (tmpImage[0].complete) {
      tmpImage.trigger("load");
    }

    // Trigger `"popstate"` to kick start image zooming.
    viewport.trigger("popstate");
  });
}(jQuery));
