import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['item']

  /**
   * Stimulus
   */

  connect() {
    const localStorageStatus = localStorage.getItem('lato_guide')
    this.status = localStorageStatus ? JSON.parse(localStorageStatus) : {}
    this.items = null
    this.showing = false
    
    this.storeStatus()
    this.setupItems()
    this.showGuide()
  }

  itemTargetConnected(e) {
    this.setupItems()
    this.showGuide()
  }

  itemTargetDisconnected(e) {
    this.setupItems()
  }

  setupItems(e = null) {
    if (e) e.preventDefault()

    this.items = this.itemTargets.map(item => ({ element: item, key: item.dataset.guideKey, content: item.dataset.guideContent, index: parseInt(item.dataset.guideIndex) })).map(item => {
      item.index = isNaN(item.index) ? 999 : item.index
      return item
    }).sort((a, b) => a.index - b.index)
  }

  async showGuide() {
    if (this.showing) return
    if (!this.status) return
    if (!this.items) return

    for (const item of this.items) {
      if (this.status[item.key]) continue
      await this.showGuideItem(item)
    }
  }

  async showGuideItem(item) {
    if (this.showing) return
    if (!this.status) return
    if (this.status[item.key]) return

    this.showing = true
    return new Promise((resolve) => {
      const tooltipIsLast = this.items.filter(target => !this.status[target.key]).length === 1
      const tooltipCloseId = `lato-guide-close-${Math.random().toString(36).substring(7)}`
      const tooltipTitle = `
        <div class="px-2 py-2 d-flex align-items-center justify-content-between">
          <p class="me-2 mb-0 text-start">${item.content}</p>
          <a id="${tooltipCloseId}" class="btn btn-light btn-sm">${tooltipIsLast ? 'Close' : 'Next'}</a>
        </div>
      `

      const tooltip = new bootstrap.Tooltip(item.element, { title: tooltipTitle, trigger: 'manual', html: true, customClass: 'lato-guide-tooltip' })
      item.element.addEventListener('shown.bs.tooltip', () => {
        setTimeout(() => {
          document.getElementById(tooltipCloseId).addEventListener('click', () => {
            tooltip.hide()
            this.showing = false
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
    this.showGuide()
  }
}