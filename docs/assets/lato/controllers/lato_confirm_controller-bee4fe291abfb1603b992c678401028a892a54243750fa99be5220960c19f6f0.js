import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'modalBody'
  ]

  connect() {
    this.modal = new bootstrap.Modal(this.element)
    Turbo.setConfirmMethod(this.customConfirm.bind(this))

    this.element.addEventListener('show.bs.modal', () => {
      this.element.style.zIndex = 2001

      // update backdrop z-index to be sure is always above other modals
      setTimeout(() => { // use setTimeout because bsModalBackdropElement is not always ready after 'show.bs.modal' event
        const bsModalBackdropElement = this.modal._backdrop._element
        if (bsModalBackdropElement) bsModalBackdropElement.style.zIndex = 2000
      }, 1)
    })
  }

  disconnect() {
    Turbo.setConfirmMethod(window.confirm)
  }

  async customConfirm(message) {
    this.modalBodyTarget.innerHTML = message
    this.modal.show()

    this._result = undefined
    while (this._result === undefined) {
      await new Promise(resolve => setTimeout(resolve, 100))
    }

    return this._result
  }

  confirmSuccess() {
    this.hideModal()
    this._result = true
  }

  confirmCancel() {
    this.hideModal()
    this._result = false
  }

  hideModal() {
    this.modal.hide()
    setTimeout(() => this.modalBodyTarget.innerHTML = '', 500)
  }
};
