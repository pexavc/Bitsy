var s_ajaxListener = new Object();
s_ajaxListener.tempSend = XMLHttpRequest.prototype.send;
s_ajaxListener.callback = function () {
    // this.method :the ajax method used
    // this.url    :the url of the requested script (including query string, if any) (urlencoded)
    // this.data   :the data sent, if any ex: foo=bar&a=b (urlencoded)
    console.log(`url: ${this.url}`)
}

XMLHttpRequest.prototype.openParent = XMLHttpRequest.prototype.open;
XMLHttpRequest.prototype.open = function (...params) {
    if (params[1].includes("/livestream")) {
        this.addEventListener('load', function() {
            // do something with the response text
            var json = JSON.parse(this.responseText);
            webkit.messageHandlers.callbackHandler.postMessage("StreamURL: " + json.data.playback_url);
        });
    }
    
    //    console.log("########## NEW REQUEST");
    //    console.log(params);
    
    
    this.openParent(...params);
};
