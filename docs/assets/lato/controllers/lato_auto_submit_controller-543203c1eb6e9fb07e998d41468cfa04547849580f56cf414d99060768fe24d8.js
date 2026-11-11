import { Controller } from "@hotwired/stimulus"

// Submits the form as soon as it is rendered. Keep a visible submit button as fallback when JavaScript is disabled.
export default class extends Controller {
  connect() {
    this.element.requestSubmit()
  }
};
