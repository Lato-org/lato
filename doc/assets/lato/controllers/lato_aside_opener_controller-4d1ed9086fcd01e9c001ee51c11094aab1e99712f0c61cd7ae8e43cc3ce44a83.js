import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  /**
   * Functions
   */

  toggle() {
    document.body.classList.toggle('aside-open')
  }

  /**
   * Actions
   */

  onClickToggle(e) {
    e.preventDefault()
    document.body.classList.toggle('aside-open')
  }
};
