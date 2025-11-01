import Request from "./request";
import Denied from "./denied";
import Granted from "./granted";

customElements.define("action-push-web-request", Request);
customElements.define("action-push-web-denied", Denied);
customElements.define("action-push-web-granted", Granted);
