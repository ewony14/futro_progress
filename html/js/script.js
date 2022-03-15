$('document').ready(function() {
    FutroProgBar = {};

    FutroProgBar.Progress = function(data) {
        $(".progress-container").css({"display":"block"});
        $("#progress-label").text(data.label);
        $("#progress-bar").stop().css({"width": 0, "background": "linear-gradient(to bottom right, #173347 25%, #05499c 100%)"}).animate({
          width: '100%'
        }, {
          duration: parseInt(data.duration),
          complete: function() {
            $(".progress-container").css({"display":"none"});
            $("#progress-bar").css("width", 0);
            $.post('http://futro_progress/actionFinish', JSON.stringify({
                })
            );
          }
        });
    };

    FutroProgBar.ProgressCancel = function() {
        $(".progress-container").css({"display":"block"});
        $("#progress-label").text("CANCELLED");
        $("#progress-bar").stop().css( {"width": "100%", "background-color": "#ff0000"});

        setTimeout(function () {
            $(".progress-container").css({"display":"none"});
            $("#progress-bar").css("width", 0);
            $.post('http://futro_progress/actionCancel', JSON.stringify({
                })
            );
        }, 1000);
    };

    FutroProgBar.CloseUI = function() {
        $('.main-container').css({"display":"none"});
        $(".character-box").removeClass('active-char');
        $(".character-box").attr("data-ischar", "false")
        $("#delete").css({"display":"none"});
    };
    
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case 'futro_progress':
                FutroProgBar.Progress(event.data);
                break;
            case 'futro_progress_cancel':
                FutroProgBar.ProgressCancel();
                break;
        }
    })
});