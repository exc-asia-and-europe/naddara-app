$(function() {
    var tallest = 0;

    $("#results li").each(function () {
        if ($(this).height() > tallest) {
            tallest = $(this).height();
        }
    });
    $("#results li").each(function() {
        $(this).height(tallest);
    });
    
    $(".info").click(function (ev) {
        ev.preventDefault();
        $.ajax({
            url: this.href,
            success: function (data) {
                $("#metadata .content").html(data);
                $("#metadata").show(500);
            }
        });
    });
    
    $("#metadata .close").click(function (ev) {
        $("#metadata").hide(500);
    });
    
    var gallery = new naddara.galleries.Viewer($("#lightbox"), "modules/search");
    $(".icon img").click(function (ev) {
        // ev.preventDefault();
        var pageCount = parseInt($(this).attr("pages"), 10);
        var modsUUID = $(this).attr("mods-uuid");
        if (pageCount > 0) {
            gallery.open();
            gallery.show(1, modsUUID);
        } else {
            var link = $(this).parent().parent().find("a:first");
            console.log("link: %o", link);
            link.each(function () {
                window.location = this.href;
            });
        }
    });
});

/* Debug and logging functions */
(function($) {
    $.log = function() {
//      if (typeof console == "undefined" || typeof console.log == "undefined") {
//          console.log( Array.prototype.slice.call(arguments) );
        if(window.console && window.console.log) {
            console.log.apply(window.console,arguments);
        }
    };
    $.fn.log = function() {
        $.log(this);
        return this;
    };
})(jQuery);