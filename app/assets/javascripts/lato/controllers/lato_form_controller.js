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
   * Actions
   */

  onInputChange(e) {
    e.target.classList.remove('is-invalid')
  }
}
