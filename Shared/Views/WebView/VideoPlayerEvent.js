/*
 
 Helps us detect when a video html element "starts playing"
 Allowing to faithfully pull correct URLs and or swizzle at
 the right time.
 
 */

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

function setupVideoPlayingListener() {
    if (videoTags().length > 0) {
        setupVideoPlayingHandler();
        return
    }

    setTimeout(setupVidePlayingListener, 100);
}

setupVideoPlayingListener();
