window.addEventListener("load", () => {
    webkit.messageHandlers.callbackHandler.postMessage("Loaded");
});
