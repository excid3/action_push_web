export default class Denied extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.hidden = !this.isEnabled;
    document.addEventListener('action-push-web:granted', this.attributeChangedCallback.bind(this));
    document.addEventListener('action-push-web:denied', this.attributeChangedCallback.bind(this));
  }

  disconnectedCallback() {
    document.removeEventListener('action-push-web:granted', this.attributeChangedCallback.bind(this));
    document.removeEventListener('action-push-web:denied', this.attributeChangedCallback.bind(this));
  }

  attributeChangedCallback() {
    this.hidden = !this.isEnabled;
  }

  get isEnabled() {
    return !navigator.serviceWorker || !window.Notification || Notification.permission == "denied"
  }
}
