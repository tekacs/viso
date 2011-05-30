(function($) {
  $(function() {
    var viewport     = $(window),
        body         = $("body"),
        image        = $("img"),
        headerHeight = $("h2").height(),
        imagePadding = 0,
        fullHeight   = 0;

    image

      // Save the image's full height and calculate the padding above the image
      // to use when determining if the image should be scaled down to fit
      // within the window.
      .load(function() {
        fullHeight   = this.height;
        imagePadding = (image.position().top - headerHeight) * 2;

        image
          .data("initialized", true)
          .trigger("resize");
      })

      // Check the current viewport height and resize the image to fit
      // comfortably. Add the class "zoom-in" on **body** if the image has been
      // zoomed in or remove it if the image fits within the viewport.
      .bind("resize", function(e) {
        // Stop this event from bubbling up to window.
        e.stopPropagation();

        // Only attempt to resize if the image has been initialized.
        if (!image.data("initialized")) { return; }

        var maxHeight = viewport.height() - headerHeight - imagePadding - 2;

        if (fullHeight > maxHeight) {
          body.addClass("zoom-in");
          image.css({ maxHeight: maxHeight });
        }
      })

      // Handle clicks on the image and toggle the class "zoom" on **body**.
      .click(function() {
        $("body").toggleClass("zoom");
      });

    // Make sure the load event fires even if the image is cached.
    if (image[0].complete) {
      image.trigger("load");
    }

    // Resize the image when the window is resized.
    viewport.resize(function() {
      image.trigger("resize");
    });
  });
}(jQuery));
