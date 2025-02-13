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

    this.connected = true
    this.tooltip = null
    this.run()

    window.addEventListener('resize', this.onWindowResize.bind(this))
  }

  disconnect() {
    this.storeStatus()

    if (this.tooltip) {
      this.tooltip.hide()
      this.tooltip.dispose()
      this.tooltip = null
    }

    this.connected = false

    window.removeEventListener('resize', this.onWindowResize.bind(this))
  }

  itemTargetConnected(e) {
    this.run()
  }

  itemTargetDisconnected(e) {
    if (this.tooltip && this.tooltip.itemKey === e.target.dataset.guideKey) {
      this.tooltip.hide()
      this.tooltip.dispose()
      this.tooltip = null
    }
  }

  /**
   * Exposed functions
   */

  rerun(e = null) {
    if (e) e.preventDefault()
    this.resetStatus()
    this.run()
  }

  run(e = null) {
    if (e) e.preventDefault()
    if (!this.connected) return

    const items = this.getNotShowedItems()
    if (items.length === 0) return

    this.showItem(items[0])
  }

  /**
   * Helpers
   */

  getNotShowedItems() {
    const items = this.itemTargets.map(item => ({ element: item, key: item.dataset.guideKey, content: item.dataset.guideContent, index: parseInt(item.dataset.guideIndex) })).map(item => {
      item.index = isNaN(item.index) ? 999 : item.index
      return item
    }).sort((a, b) => a.index - b.index).filter((item) => !this.status[item.key])

    return items
  }

  showItem(item) {
    if (!this.status) return
    if (this.status[item.key]) return
    if (this.tooltip) return

    // setup tooltip
    const tooltipCloseId = `lato-guide-close-${Math.random().toString(36).substring(7)}`
    const tooltipTitle = `
      <div class="px-2 py-2 d-flex align-items-center justify-content-between">
        <p class="me-2 mb-0 text-start">${item.content}</p>
        <a id="${tooltipCloseId}" class="btn btn-light btn-sm">Next</a>
      </div>
    `
    this.tooltip = new bootstrap.Tooltip(item.element, { title: tooltipTitle, trigger: 'manual', html: true, customClass: 'lato-guide-tooltip' })
    this.tooltip.itemKey = item.key
    
    // listen to tooltip close
    item.element.addEventListener('shown.bs.tooltip', () => {
      setTimeout(() => {
        document.getElementById(tooltipCloseId).addEventListener('click', () => {
          this.tooltip.hide()
          this.tooltip.dispose()
          this.tooltip = null
          this.status[item.key] = true
          this.storeStatus()
          this.run()
        })
      }, 250)
    })
    this.tooltip.show()  

    return true
  }

  storeStatus() {
    localStorage.setItem('lato_guide', JSON.stringify(this.status))

    return true
  }

  resetStatus() {
    this.status = {}
    this.storeStatus()

    return true
  }

  /**
   * Events
   */

  onWindowResize(e) { // on window resize, repostion tooltip
    if (this.tooltip) {
      this.tooltip.hide()
      this.tooltip.show()
    }
  }
}