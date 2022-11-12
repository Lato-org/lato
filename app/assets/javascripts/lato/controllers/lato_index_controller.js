import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'modal',
    'modalBody'
  ]

  connect() {
    this.bsModal = new bootstrap.Modal(this.modalTarget)
  }
  
  onActionClick(e) {
    const targetTurboFrame = e.currentTarget.getAttribute('data-turbo-frame')
    if (targetTurboFrame != '_top') {
      this.modalBodyTarget.innerHTML = `<turbo-frame id="${targetTurboFrame}"></turbo-frame>`
      this.bsModal.show()
    }
  }
}
