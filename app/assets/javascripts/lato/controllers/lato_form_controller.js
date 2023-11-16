import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'submit',
    'input'
  ]

  // NOTE: This controller is free for be used in future form improvements.

  /**
   * Stimulus
   */

  connect() {}

  /**
   * Events
   */

  onInputChange(e) {
    e.target.classList.remove('is-invalid')
  }

  // NOTE: You can use this method to submit the form from outside the form or from custom DOM actions.
  submit() {
    this.element.submit()
  }
}
