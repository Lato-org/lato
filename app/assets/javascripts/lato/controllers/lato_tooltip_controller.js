import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  /**
   * Stimulus
   */

  connect() {
    this.tooltip = new bootstrap.Tooltip(this.element)

    // Always close the tooltip when its trigger element is clicked, since the
    // click may move the element and leave the tooltip stuck in the old position
    this.element.addEventListener('click', () => this.tooltip.hide())

    // HACK: Force tooltip to be closed when a boostrap modal is opened/closed
    const modals = document.querySelectorAll('.modal')
    modals.forEach((modal) => {
      modal.addEventListener('show.bs.modal', () => {
        setTimeout(() => this.tooltip.hide(), 0)
      })
      modal.addEventListener('hide.bs.modal', () => {
        setTimeout(() => this.tooltip.hide(), 0)
      })
    })
  }

  disconnect() {
    this.tooltip.dispose()
  }
}
