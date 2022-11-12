import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.bsFeedback = new bootstrap.Toast(this.element)
    this.bsFeedback.show()
  }
}
