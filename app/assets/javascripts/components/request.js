export default class Request extends HTMLElement {
  static observedAttributes = ["href"];

  constructor() {
    super();
  }

  connectedCallback() {
    this.setAttribute('role', 'button');
    this.#setState()

    this.addEventListener('click', this.onClick);
  }

  #setState() {
    this.hidden = !this.isEnabled;
  }

  disconnectedCallback() {
    this.removeEventListener('click', this.onClick);
  }

  attributeChangedCallback() {
    this.#setState()
  }

  get isEnabled() {
    return navigator.serviceWorker && window.Notification && Notification.permission == "default"
  }

  async onClick(event) {
    event.preventDefault();
    event.stopPropagation();

    if (this.isEnabled) {
      const permission = await Notification.requestPermission()
      if (permission === "granted") {
        document.dispatchEvent(new CustomEvent('action-push-web:granted', {}))
      } else if (permission === "denied") {
        document.dispatchEvent(new CustomEvent('action-push-web:denied', {}))
      }
      this.#setState()
    }
  }
}
