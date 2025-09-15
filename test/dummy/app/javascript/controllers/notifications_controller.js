import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    subscriptionsUrl: String,
    vapidPublicKey: String,
    serviceWorkerPath: { type: String, default: "/service-worker.js" }
  }

  async attemptToSubscribe() {
    if (this.#allowed) {
      const registration = await this.#serviceWorkerRegistration || await this.#registerServiceWorker()

      switch(Notification.permission) {
        // case "denied": { this.#revealNotAllowedNotice(); break }
        case "granted": { this.#subscribe(registration); break }
        case "default": { this.#requestPermissionAndSubscribe(registration) }
      }
    }
  }

  get #allowed() {
    return navigator.serviceWorker && window.Notification
  }

  get #serviceWorkerRegistration() {
    return navigator.serviceWorker.getRegistration(window.location.origin)
  }

  async #requestPermissionAndSubscribe(registration) {
    const permission = await Notification.requestPermission()
    if (permission === "granted") this.#subscribe(registration)
  }

  #registerServiceWorker() {
    return navigator.serviceWorker.register(this.serviceWorkerPathValue)
  }

  async #subscribe(registration) {
    registration.pushManager
      .subscribe({ userVisibleOnly: true, applicationServerKey: this.#vapidPublicKey })
      .then(subscription => {
        this.#syncPushSubscription(subscription)
        this.dispatch("ready")
      })
  }

  async #syncPushSubscription(subscription) {
    const response = await fetch(this.subscriptionsUrlValue, {
      method: "POST",
      body: this.#extractJsonPayloadAsString(subscription),
      headers: {
        Accept: "text/vnd.turbo-stream.html, text/html, application/xhtml+xml",
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content
      }
    })
    if (!response.ok) subscription.unsubscribe()
  }

  #extractJsonPayloadAsString(subscription) {
    const { endpoint, keys: { p256dh, auth } } = subscription.toJSON()
    return JSON.stringify({ push_subscription: { endpoint, p256dh_key: p256dh, auth_key: auth } })
  }

  get #vapidPublicKey() {
    const encodedVapidPublicKey = this.vapidPublicKeyValue || document.querySelector('meta[name="vapid-public-key"]').content
    return this.#urlBase64ToUint8Array(encodedVapidPublicKey)
  }

  // VAPID public key comes encoded as base64 but service worker registration needs it as a Uint8Array
  #urlBase64ToUint8Array(base64String) {
    const padding = "=".repeat((4 - base64String.length % 4) % 4)
    const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/")

    const rawData = window.atob(base64)
    const outputArray = new Uint8Array(rawData.length)

    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i)
    }

    return outputArray
  }
}
