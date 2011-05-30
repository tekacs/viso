(function($) {
  $(function() {
    var viewport     = $(window),
        body         = $("body"),
        image        = $("img"),
        imagePadding = 50 * 2,
        headerHeight = 42,
        fullHeight   = 0;

    image
      .load(function() {
        fullHeight = this.height;

        image
          .data("initialized", true)
          .trigger("resize");
      })

      .bind("resize", function(e) {
        // Stop this event from bubbling up to window.
        e.stopPropagation();

        // Wait until the image is initialized before attempting to resize.
        if (!image.data("initialized")) { return; }

        var maxHeight = viewport.height() - headerHeight - imagePadding;

        if (fullHeight > maxHeight) {
          image.css({ maxHeight: maxHeight });
        }
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
