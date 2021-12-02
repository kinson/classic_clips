import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"

let Hooks = {}
Hooks.PickEmThemeData = {
  updated() {
    window.localStorage.setItem("theme", this.el.attributes.value.value);
  },
};

const defaultTheme = JSON.stringify({"enable_emojis": false, "enable_emoji_only": false, "emoji_overrides": {}})

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  params: {
    theme: window.localStorage.getItem("theme") || defaultTheme,
    _csrf_token: csrfToken
  },
  hooks: Hooks
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// set up on click listener for copying clip link
const copyLinkButton = document.getElementById("share-clip-text-button");
const copyLinkInputField = document.getElementById("clip-link-external");

const copyLinkPTagBefore = document.getElementById("copy-link-p-before");
const copyLinkPTagAfter = document.getElementById("copy-link-p-after");

copyLinkInputField.addEventListener('click', function(e) {
    e.preventDefault();
    copyLinkButton.focus();
});

copyLinkButton.addEventListener('click', function() {
    copyLinkInputField.focus();
    copyLinkInputField.select();
    document.execCommand('copy');

    copyLinkPTagBefore.classList.add('hidden');
    copyLinkPTagAfter.classList.remove('hidden');
    copyLinkButton.focus();
});
