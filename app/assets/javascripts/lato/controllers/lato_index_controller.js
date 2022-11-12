import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'modal',
    'modalBody',
    'action'
  ]

  connect() {
    this.bsModal = new bootstrap.Modal(this.modalTarget)

    this.actionTargets.forEach((action) => {
      action.addEventListener('click', (e) => this.onActionClick(e))
    })
  }
  
  onActionClick(e) {
    console.log('lato_index.onActionClick')

    const targetTurboFrame = e.currentTarget.getAttribute('data-turbo-frame')
    if (targetTurboFrame && targetTurboFrame != '_top') {
      console.log('lato_index.onActionClick', 'manage internal')
      this.modalBodyTarget.innerHTML = `<turbo-frame id="${targetTurboFrame}"></turbo-frame>`
      this.bsModal.show()
    }
  }
}
