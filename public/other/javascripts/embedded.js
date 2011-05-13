$(function() {
  var
    toolbar = $("#toolbar"),
    speed = 200,
    closeAnimationPositions = [ 3, 2, 1, 0, 5, 4, 3, 2, 1, 0 ],
    closeSpeed = Math.round(speed / closeAnimationPositions.length),

    close = $(".close a").click(function (e) {
      e.preventDefault();

      if (toolbar.is(":animated")) {
        return;
      }

      var hide = (toolbar.css("bottom") == "0px");

      toolbar.animate({
        bottom: (hide ? -33 : 0),
        opacity: (hide ? 0 : 100)
      }, speed);

      var positions = closeAnimationPositions.slice(0);
      if (hide) {
        positions.reverse();
      }

      $(positions).each(function(i, position) {
        var offset = position * -19;
        setTimeout(function() {
          close.css({ backgroundPosition: "0 " + offset + "px" });
        }, i * closeSpeed);
      });
    });

    $('#embed_url').click(function() {
      $(this).focus().select();
    });

});
