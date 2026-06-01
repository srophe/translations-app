$(document).ready(function () {
    // Main javascript functions the application
    
    
    //Show hide footnotes
    $('html').click(function () {
        $('#footnoteDisplay').hide();
        $('#footnoteDisplay div.content').empty();
    })
    
    $('.footnote-ref a').click(function (e) {
        e.stopPropagation();
        e.preventDefault();
        var link = $(this);
        var href = $(this).attr('href');
        var content = $(href).html()
        $('#footnoteDisplay').css('display', 'block');
        $('#footnoteDisplay').css({
            'top': e.pageY -50, 'left': e.pageX + 25, 'position': 'absolute'
        });
        $('#footnoteDisplay div.content').html(content);
    });
    
    //Toggle
    $('input.toggleDisplay').click(function () {
        var display = $(this).data("element");
        $('.' + display).toggleClass("active block")
        var section = $('.' + display).hasClass("tei-head");
        //Change checkbox to active
        $(this).toggleClass("active");
        console.log(display);
    });
    
    $('button.toggleHead').click(function () {
        $('.head').toggleClass("hidden");
    });
    
    //search sedra
    $('a.sedra').click(function (e) {
        //event.preventDefault();
        e.stopPropagation();
        e.preventDefault();
        var href = $(this).attr('href');
        $('#sedraDisplay').css('display', 'block');
        $. get (href, function (data) {
            $("#sedraContent div.content").html(data);
        }).fail(function () {
            $('#sedraContent div.content').empty();
            $("#sedraContent div.content").html('There are no results for this word. Please try using the <a href="http://sedra.bethmardutho.org/">Syriac Dictionary Lookup</a>');
        });
    });
    
    $('html').click(function () {
        $('#sedraDisplay').hide();
        $('#footnoteDisplay').hide();
        $('#sedraContent div.content').empty();
        $('#footnoteDisplay div.content').empty();
    })
    
    $('#rightCol').click(function (e) {
        e.stopPropagation();
    });
    
    $('.footnote-ref a').click(function (e) {
        e.stopPropagation();
        e.preventDefault();
        var link = $(this);
        var href = $(this).attr('href');
        var content = $(href).html()
        $('#footnoteDisplay').css('display', 'block');
        $('#footnoteDisplay').css({
            'top': e.pageY -50, 'left': e.pageX + 25, 'position': 'absolute'
        });
        $('#footnoteDisplay div.content').html(content);
    });
});