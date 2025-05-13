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

  connect() {
    this.hiddenSubmit = document.createElement('input')
    this.hiddenSubmit.type = 'submit'
    this.hiddenSubmit.style.display = 'none'
    this.element.appendChild(this.hiddenSubmit)
  }

  disconnect() {
    this.hiddenSubmit.remove()
  }

  /**
   * Events
   */

  // This event is used to remove the Bootstrap invalid class from the input when the user starts typing.
  onInputChange(e) {
    e.target.classList.remove('is-invalid')
  }

  // NOTE: You can use this method to submit the form from outside the form or from custom DOM actions.
  submit() {
    this.hiddenSubmit.click()
  }
};
