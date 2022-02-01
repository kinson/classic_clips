import 'phoenix_html';
import { Socket } from 'phoenix';
import { LiveSocket } from 'phoenix_live_view';

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute('content');

let liveSocket = new LiveSocket('/live', Socket, {
  params: {
    _csrf_token: csrfToken,
  },
});

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// set up on click listener for copying clip link
const copyLinkButton = document.getElementById('share-clip-text-button');
const copyLinkInputField = document.getElementById('clip-link-external');

const copyLinkPTagBefore = document.getElementById('copy-link-p-before');
const copyLinkPTagAfter = document.getElementById('copy-link-p-after');

if (copyLinkInputField) {
  copyLinkInputField.addEventListener('click', function (e) {
    e.preventDefault();
    copyLinkButton.focus();
  });

  copyLinkButton.addEventListener('click', function () {
    copyLinkInputField.focus();
    copyLinkInputField.select();
    document.execCommand('copy');

    copyLinkPTagBefore.classList.add('hidden');
    copyLinkPTagAfter.classList.remove('hidden');
    copyLinkButton.focus();
  });
}

let notificationTimeout;

function hideNotification() {
  if (notificationTimeout) clearTimeout(notificationTimeout);
  let el = document.getElementById('notification');

  if (el) {
    el.classList.replace('-translate-y-12', 'translate-y-0');
    el.classList.add('opacity-0');

    setTimeout(() => {
      el.classList.add('invisible', 'h-0');
    }, 150);
  }
}

function showNotification() {
  if (notificationTimeout) clearTimeout(notificationTimeout);
  let el = document.getElementById('notification');

  if (el) {
    el.classList.remove('invisible', 'h-0', 'opacity-0');
    el.classList.replace('translate-y-0', '-translate-y-12');

    notificationTimeout = setTimeout(hideNotification, 2500);
  }
}

window.addEventListener('phx:show-notification', showNotification);
window.addEventListener('phx:close-notification', hideNotification);
