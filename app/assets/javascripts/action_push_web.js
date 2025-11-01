// app/assets/javascripts/components/request.js
class Request extends HTMLElement {
  static observedAttributes = ["href"];
  constructor() {
    super();
  }
  connectedCallback() {
    this.setAttribute("role", "button");
    this.#setState();
    this.addEventListener("click", this.onClick);
  }
  #setState() {
    this.hidden = !this.isEnabled;
  }
  disconnectedCallback() {
    this.removeEventListener("click", this.onClick);
  }
  attributeChangedCallback() {
    this.#setState();
  }
  get isEnabled() {
    return navigator.serviceWorker && window.Notification && Notification.permission == "default";
  }
  async onClick(event) {
    event.preventDefault();
    event.stopPropagation();
    if (this.isEnabled) {
      const permission = await Notification.requestPermission();
      if (permission === "granted") {
        document.dispatchEvent(new CustomEvent("action-push-web:granted", {}));
      } else if (permission === "denied") {
        document.dispatchEvent(new CustomEvent("action-push-web:denied", {}));
      }
      this.#setState();
    }
  }
}

// app/assets/javascripts/components/denied.js
class Denied extends HTMLElement {
  constructor() {
    super();
  }
  connectedCallback() {
    this.hidden = !this.isEnabled;
    document.addEventListener("action-push-web:granted", this.attributeChangedCallback.bind(this));
    document.addEventListener("action-push-web:denied", this.attributeChangedCallback.bind(this));
  }
  disconnectedCallback() {
    document.removeEventListener("action-push-web:granted", this.attributeChangedCallback.bind(this));
    document.removeEventListener("action-push-web:denied", this.attributeChangedCallback.bind(this));
  }
  attributeChangedCallback() {
    this.hidden = !this.isEnabled;
  }
  get isEnabled() {
    return !navigator.serviceWorker || !window.Notification || Notification.permission == "denied";
  }
}

// app/assets/javascripts/components/granted.js
class Granted extends HTMLElement {
  constructor() {
    super();
  }
  connectedCallback() {
    document.addEventListener("action-push-web:granted", this.attributeChangedCallback.bind(this));
    document.addEventListener("action-push-web:denied", this.attributeChangedCallback.bind(this));
    this.#setState();
  }
  disconnectedCallback() {
    document.removeEventListener("action-push-web:granted", this.attributeChangedCallback.bind(this));
    document.removeEventListener("action-push-web:denied", this.attributeChangedCallback.bind(this));
  }
  attributeChangedCallback() {
    this.#setState();
  }
  async#subscribe() {
    const registration = await this.#serviceWorkerRegistration || await this.#registerServiceWorker();
    registration.pushManager.subscribe({ userVisibleOnly: true, applicationServerKey: this.#vapidPublicKey }).then((subscription) => {
      this.#syncPushSubscription(subscription);
    });
  }
  get #isEnabled() {
    return !!navigator.serviceWorker && !!window.Notification && Notification.permission == "granted" && this.getAttribute("href") && this.getAttribute("public-key");
  }
  get #serviceWorkerRegistration() {
    return navigator.serviceWorker.getRegistration();
  }
  get #vapidPublicKey() {
    return this.#urlBase64ToUint8Array(this.getAttribute("public-key"));
  }
  async#syncPushSubscription(subscription) {
    const response = await fetch(this.getAttribute("href"), {
      method: "POST",
      body: this.#extractJsonPayloadAsString(subscription),
      headers: {
        Accept: "text/vnd.turbo-stream.html, text/html, application/xhtml+xml",
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content
      }
    });
    if (!response.ok)
      subscription.unsubscribe();
  }
  #extractJsonPayloadAsString(subscription) {
    const { endpoint, keys: { p256dh, auth } } = subscription.toJSON();
    return JSON.stringify({ push_subscription: { endpoint, p256dh_key: p256dh, auth_key: auth } });
  }
  #setState() {
    this.hidden = !this.#isEnabled;
    if (this.#isEnabled) {
      this.#subscribe();
    }
  }
  #urlBase64ToUint8Array(base64String) {
    const padding = "=".repeat((4 - base64String.length % 4) % 4);
    const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/");
    const rawData = window.atob(base64);
    const outputArray = new Uint8Array(rawData.length);
    for (let i = 0;i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i);
    }
    return outputArray;
  }
  #registerServiceWorker() {
    return navigator.serviceWorker.register(this.getAttribute("service-worker-url"));
  }
}

// app/assets/javascripts/components/action_push_web.js
customElements.define("action-push-web-request", Request);
customElements.define("action-push-web-denied", Denied);
customElements.define("action-push-web-granted", Granted);
