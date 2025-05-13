import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  /**
   * Stimulus
   */

  connect() {
  }

  /**
   * Events
   */

  // This event is used to reset the pagination when the user types in the search input to start a new search.
  onSearchKeyUp(e) {
    const pageInput = this.element.querySelector('input[name="page"]')
    if (pageInput) pageInput.value = 1
  }
};
