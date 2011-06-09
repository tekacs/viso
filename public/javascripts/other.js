(function($) {
  $(function() {
    var viewport = $(window),
        content  = $("#content"),
        wrapper  = content.closest(".wrapper"),
        link     = content.find("a");

    content

      // Center the download box vertically within the viewport accounting for
      // the padding around the body.
      .bind("center", function() {
        var viewportSize = viewport.height() - wrapper.height() - 36;

        var top = Math.floor(viewportSize / 2);
        wrapper.css({ marginTop: top });
      })

      // Trigger `"center"` to kick things off.
      .trigger("center");

    // Recenter the content when the browser is resized.
    viewport.resize(function() {
      content.trigger("center");
    });

    // Show the download button when holding the option key.
    $("body")
      .keydown(function(e) {
        if (e.altKey) {
          link.addClass("download");
        }
      })
      .keyup(function(e) {
        link.removeClass("download");
      });

  });
}(jQuery));
