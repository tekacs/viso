(function($) {
  $(function() {
    var viewport     = $(window),
        body         = $("body"),
        image        = $("img"),
        headerHeight = $("h2").height(),
        imagePadding = 0,
        fullWidth    = 0,
        fullHeight   = 0;

    // Create a temporary image to determine the full width and height of the
    // main image.
    var tmpImage = $("<img/>")
                     .attr("src", image.attr("src"))
                     .load(function() {
                       fullWidth  = this.width;
                       fullHeight = this.height;

                       tmpImage.data("initialized", true);
                       image.trigger("resize");
                     });

    // Make sure the load event fires even if the image is cached.
    if (tmpImage[0].complete) {
      tmpImage.trigger("load");
    }


    image

      // Calculate and save the padding above the image to use when determining
      // if the image should be scaled down to fit within the window.
      .load(function() {
        imagePadding = (image.position().top - headerHeight) * 2;

        image
          .data("initialized", true)
          .trigger("resize");
      })

      // Check the current viewport height and resize the image to fit
      // comfortably. Add the class "zoom-in" on **body** if the image has been
      // zoomed in or remove it if the image fits within the viewport.
      .bind("resize", function(e) {
        // Stop this event from bubbling up to `window`.
        e.stopPropagation();

        if (body.is(".zoomed-in")) { return; }

        // Only attempt to resize if the image has been initialized.
        if (!image.data("initialized") || !tmpImage.data("initialized")) { return; }

        var maxWidth  = Math.floor(viewport.width()  * 0.9),
            maxHeight = viewport.height() - imagePadding;

        if (fullWidth > maxWidth || fullHeight > maxHeight) {
          body.addClass("zoomed-out");
          image.css({ maxHeight: maxHeight });
        } else {
          body.removeClass("zoomed-out");
        }
      })

      // Handle clicks on the image to toggle its zoom. Ignore clicks unless the
      // image is zoomed in or out.
      .click(function() {
        if (!body.is(".zoomed-in, .zoomed-out")) { return; }

        if (body.is(".zoomed-in")) {
          body.removeClass("zoomed-in");
          image.trigger("resize");
        } else {
          body
            .addClass("zoomed-in")
            .removeClass("zoomed-out");
        }
      });

    // Resize the image when the window is resized.
    viewport.resize(function() {
      image.trigger("resize");
    });

    // Make sure the load event fires even if the image is cached.
    if (image[0].complete) {
      image.trigger("load");
    }
  });
}(jQuery));
