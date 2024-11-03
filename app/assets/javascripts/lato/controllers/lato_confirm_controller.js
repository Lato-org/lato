import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'modalBody'
  ]

  connect() {
    this.modal = new bootstrap.Modal(this.element)
    Turbo.setConfirmMethod(this.customConfirm.bind(this))
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
}
