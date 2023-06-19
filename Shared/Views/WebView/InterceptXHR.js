/*
 
 Primarily for Kick. Kick logs an XHR request that can be intercepted to
 fetch appropriate HLS playlist files.
 
 */

XMLHttpRequest.prototype.openParent = XMLHttpRequest.prototype.open;
XMLHttpRequest.prototype.open = function (...params) {
    if (params[1].includes("/livestream")) {
        this.addEventListener('load', function() {
            /*
             XMLHTTPRequests allow for "fine-grained server calls"
             
             which means, an object such as "responseText" can get filled with response data
             without added steps. We simply reference it below.
             
             */
            var json = JSON.parse(this.responseText);
            
            //"callbackHandler" is a custom message we set on the Swift side.
            webkit.messageHandlers.callbackHandler.postMessage("StreamURL: " + json.data.playback_url);
        });
    }
    
    this.openParent(...params);
};
