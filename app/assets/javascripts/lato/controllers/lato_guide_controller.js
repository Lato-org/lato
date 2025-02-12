import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['item']

  /**
   * Stimulus
   */

  connect() {
    const localStorageStatus = localStorage.getItem('lato_guide')
    this.status = localStorageStatus ? JSON.parse(localStorageStatus) : {}
    this.storeStatus()

    this.start()
  }

  start(e = null) {
    if (e) e.preventDefault()

    const targets = this.itemTargets.map(item => ({ element: item, key: item.dataset.guideKey, content: item.dataset.guideContent, index: parseInt(item.dataset.guideIndex) })).map(item => {
      item.index = isNaN(item.index) ? 999 : item.index
      return item
    }).sort((a, b) => a.index - b.index)

    this.showGuide(targets)
  }

  async showGuide(targets) {
    for (let i = 0; i < targets.length; i++) {
      const item = targets[i]
      if (this.status[item.key]) continue

      await this.showGuideItem(item, i === targets.length - 1)
    }
  }

  async showGuideItem(item, isLast = false) {
    if (this.status[item.key]) return

    return new Promise((resolve) => {
      const tooltipCloseId = `guide-close-${Math.random().toString(36).substring(7)}`
      const tooltipTitle = `
        <div class="px-3 py-3">
          <p class="mb-1">${item.content}</p>
          <a id="${tooltipCloseId}" class="btn btn-light btn-sm mt-2">${isLast ? 'Close' : 'Next'}</a>
        </div>
      `

      const tooltip = new bootstrap.Tooltip(item.element, { title: tooltipTitle, trigger: 'manual', html: true })
      item.element.addEventListener('shown.bs.tooltip', () => {
        setTimeout(() => {
          document.getElementById(tooltipCloseId).addEventListener('click', () => {
            tooltip.hide()
            this.status[item.key] = true
            this.storeStatus()
            resolve()
          })
        }, 250)
      })
      tooltip.show()  
    })
  }

  storeStatus(e = null) {
    if (e) e.preventDefault()
    localStorage.setItem('lato_guide', JSON.stringify(this.status))
  }

  resetStatus(e = null) {
    if (e) e.preventDefault()
    this.status = {}
    this.storeStatus()
    this.start()
  }
}