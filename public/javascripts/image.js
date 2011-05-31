(function($) {
  $(function() {
    var viewport     = $(window),
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
    viewport.resize(function() {
      max.width  = Math.floor(viewport.width()  * 0.9)
      max.height = viewport.height() - imagePadding;

      if (!body.is(".zoomed-in")) {
        image
          .css({ maxHeight: max.height })
          .trigger("zoom");
      }
    });

    image

      // Check the current viewport height and resize the image to fit
      // comfortably. Add the class "zoom-in" on **body** if the image has been
      // zoomed in or remove it if the image fits within the viewport.

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

      // Center the image vertically in the viewport leaving room for the
      // header.
      .bind("center", function() {
        var top = Math.floor((viewport.height() - headerHeight - image.height()) / 2);

        content.css({ paddingTop: top });
      })

      // Remove the top padding on `content` added when centering the image.
      .bind("uncenter", function() {
        content.css({ paddingTop: '' });
      })

      // Handle clicks on the image to toggle its zoom. Ignore clicks unless the
      // image is zoomed in or out.
      .click(function() {
        if (!body.is(".zoomed-in, .zoomed-out")) { return; }

        if (body.is(".zoomed-in")) {
          body.removeClass("zoomed-in");
          viewport.trigger("resize");
        } else {
          body
            .addClass("zoomed-in")
            .removeClass("zoomed-out")

          image.trigger("uncenter");
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
                         .trigger("zoom");
                     });

    // Make sure the load event fires even if the image is cached.
    if (tmpImage[0].complete) {
      tmpImage.trigger("load");
    }

    // Trigger `"resize"` to kick start image zooming.
    viewport.trigger("resize");
  });
}(jQuery));
