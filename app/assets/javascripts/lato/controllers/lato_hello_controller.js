import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  /**
   * Stimulus
   */

  connect() {
    this.element.textContent = "Hello Lato World!"
  }
}
