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
    viewport
      .resize(function() {
        max.width  = Math.floor(viewport.width()  * 0.9)
        max.height = viewport.height() - imagePadding;

        if (!body.is(".zoomed-in")) {
          image
            .css({ maxHeight: max.height })
            .trigger("zoom");
        }
      })

      // Handle the hashchange event to toggle the image's zoom level.
      .hashchange(function() {
        if (window.location.hash.match(/\w+/) == 'z') {
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

      // Zoom the image in.
      .bind("zoom-in", function() {
        body
          .addClass("zoomed-in")
          .removeClass("zoomed-out")

        image.trigger("uncenter");
      })

      // Zoom the image out.
      .bind("zoom-out", function() {
        body.removeClass("zoomed-in");
        viewport.trigger("resize");
      })

      // Handle lcicks on the image to toggle its zoom by toggling the hash
      // value "z". Do nothing unless the image is zoomed in or out.
      .click(function() {
        if (body.is(".zoomed-in")) {
          window.location.hash = ''
        } else if (body.is(".zoomed-out")) {
          window.location.hash = 'z'
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

    // Trigger `"hashchange"` to kick start image zooming.
    viewport.trigger("hashchange");
  });
}(jQuery));


/*
 * jQuery hashchange event - v1.3 - 7/21/2010
 * http://benalman.com/projects/jquery-hashchange-plugin/
 * 
 * Copyright (c) 2010 "Cowboy" Ben Alman
 * Dual licensed under the MIT and GPL licenses.
 * http://benalman.com/about/license/
 */
(function($,e,b){var c="hashchange",h=document,f,g=$.event.special,i=h.documentMode,d="on"+c in e&&(i===b||i>7);function a(j){j=j||location.href;return"#"+j.replace(/^[^#]*#?(.*)$/,"$1")}$.fn[c]=function(j){return j?this.bind(c,j):this.trigger(c)};$.fn[c].delay=50;g[c]=$.extend(g[c],{setup:function(){if(d){return false}$(f.start)},teardown:function(){if(d){return false}$(f.stop)}});f=(function(){var j={},p,m=a(),k=function(q){return q},l=k,o=k;j.start=function(){p||n()};j.stop=function(){p&&clearTimeout(p);p=b};function n(){var r=a(),q=o(m);if(r!==m){l(m=r,q);$(e).trigger(c)}else{if(q!==m){location.href=location.href.replace(/#.*/,"")+q}}p=setTimeout(n,$.fn[c].delay)}$.browser.msie&&!d&&(function(){var q,r;j.start=function(){if(!q){r=$.fn[c].src;r=r&&r+a();q=$('<iframe tabindex="-1" title="empty"/>').hide().one("load",function(){r||l(a());n()}).attr("src",r||"javascript:0").insertAfter("body")[0].contentWindow;h.onpropertychange=function(){try{if(event.propertyName==="title"){q.document.title=h.title}}catch(s){}}}};j.stop=k;o=function(){return a(q.location.href)};l=function(v,s){var u=q.document,t=$.fn[c].domain;if(v!==s){u.title=h.title;u.open();t&&u.write('<script>document.domain="'+t+'"<\/script>');u.close();q.location.hash=v}}})();return j})()})(jQuery,this);
