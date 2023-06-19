function videoTags() {
    return document.getElementsByTagName("video");
}

function setupVideoPlayingHandler() {
    try {
        var videos = videoTags()
        for (var i = 0; i < videos.length; i++) {
            videos.item(i).onplaying = function() {
                webkit.messageHandlers.callbackHandler.postMessage("VideoIsPlaying");
            }
        }
    } catch (error) {
        console.log(error);
    }
}

function setupVidePlayingListener() {
    if (videoTags().length > 0) {
        setupVideoPlayingHandler();
        return
    }

    setTimeout(setupVidePlayingListener, 100);
}

setupVidePlayingListener();
