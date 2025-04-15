import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  /**
   * Stimulus
   */

  connect() {
  }

  onSearchKeyUp(e) {
    // Search the input with name "page" inside this.element and force value to 1
    const pageInput = this.element.querySelector('input[name="page"]')
    if (pageInput) pageInput.value = 1
  }
};
