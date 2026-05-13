import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas", "fileInput", "uploadInput", "preview", "drawPanel", "uploadPanel", "drawTab", "uploadTab", "currentTab", "currentPanel", "clearRow"]
  static values = {
    existingUrl: String,
    defaultTab: String
  }

  connect() {
    this.isDrawing = false
    this.hasDrawing = false
    this.activeTab = this.defaultTabValue || 'draw'
    this._submitting = false

    if (this.hasCanvasTarget) {
      this._setupCanvas()
    }

    // Nascondi il pulsante clear se si parte sulla tab current
    this._updateClearRow()

    this._form = this.element.closest('form')
    if (this._form) {
      this._boundSubmit = this.onFormSubmit.bind(this)
      this._form.addEventListener('submit', this._boundSubmit)
    }
  }

  disconnect() {
    if (this._form && this._boundSubmit) {
      this._form.removeEventListener('submit', this._boundSubmit)
    }
  }

  _setupCanvas() {
    const canvas = this.canvasTarget
    // Use fixed internal resolution; CSS handles display size
    canvas.width = 800
    canvas.height = 200

    const ctx = canvas.getContext('2d')
    ctx.strokeStyle = '#1a1a1a'
    ctx.lineWidth = 2.5
    ctx.lineCap = 'round'
    ctx.lineJoin = 'round'
    this._ctx = ctx
  }

  _getPos(clientX, clientY) {
    const canvas = this.canvasTarget
    const rect = canvas.getBoundingClientRect()
    const scaleX = canvas.width / rect.width
    const scaleY = canvas.height / rect.height
    return {
      x: (clientX - rect.left) * scaleX,
      y: (clientY - rect.top) * scaleY
    }
  }

  onMouseDown(e) {
    if (this.activeTab !== 'draw') return
    this.isDrawing = true
    const pos = this._getPos(e.clientX, e.clientY)
    this._ctx.beginPath()
    this._ctx.moveTo(pos.x, pos.y)
  }

  onMouseMove(e) {
    if (!this.isDrawing) return
    e.preventDefault()
    const pos = this._getPos(e.clientX, e.clientY)
    this._ctx.lineTo(pos.x, pos.y)
    this._ctx.stroke()
    this.hasDrawing = true
  }

  onMouseUp() {
    this.isDrawing = false
  }

  onMouseLeave() {
    this.isDrawing = false
  }

  onTouchStart(e) {
    if (this.activeTab !== 'draw') return
    e.preventDefault()
    this.isDrawing = true
    const touch = e.touches[0]
    const pos = this._getPos(touch.clientX, touch.clientY)
    this._ctx.beginPath()
    this._ctx.moveTo(pos.x, pos.y)
  }

  onTouchMove(e) {
    if (!this.isDrawing) return
    e.preventDefault()
    const touch = e.touches[0]
    const pos = this._getPos(touch.clientX, touch.clientY)
    this._ctx.lineTo(pos.x, pos.y)
    this._ctx.stroke()
    this.hasDrawing = true
  }

  onTouchEnd() {
    this.isDrawing = false
  }

  switchToCurrentTab(e) {
    e.preventDefault()
    this.activeTab = 'current'
    if (this.hasCurrentPanelTarget) this.currentPanelTarget.classList.remove('d-none')
    this.drawPanelTarget.classList.add('d-none')
    this.uploadPanelTarget.classList.add('d-none')
    if (this.hasCurrentTabTarget) this.currentTabTarget.classList.add('active')
    this.drawTabTarget.classList.remove('active')
    this.uploadTabTarget.classList.remove('active')
    // Nessun nuovo file: mantieni la firma esistente
    this.fileInputTarget.value = ''
    this._updateClearRow()
  }

  switchToDrawTab(e) {
    e.preventDefault()
    this.activeTab = 'draw'
    if (this.hasCurrentPanelTarget) this.currentPanelTarget.classList.add('d-none')
    this.drawPanelTarget.classList.remove('d-none')
    this.uploadPanelTarget.classList.add('d-none')
    if (this.hasCurrentTabTarget) this.currentTabTarget.classList.remove('active')
    this.drawTabTarget.classList.add('active')
    this.uploadTabTarget.classList.remove('active')
    this._updateClearRow()
  }

  switchToUploadTab(e) {
    e.preventDefault()
    this.activeTab = 'upload'
    if (this.hasCurrentPanelTarget) this.currentPanelTarget.classList.add('d-none')
    this.drawPanelTarget.classList.add('d-none')
    this.uploadPanelTarget.classList.remove('d-none')
    if (this.hasCurrentTabTarget) this.currentTabTarget.classList.remove('active')
    this.drawTabTarget.classList.remove('active')
    this.uploadTabTarget.classList.add('active')
    this._updateClearRow()
  }

  _updateClearRow() {
    if (!this.hasClearRowTarget) return
    if (this.activeTab === 'current') {
      this.clearRowTarget.classList.add('d-none')
    } else {
      this.clearRowTarget.classList.remove('d-none')
    }
  }

  clearSignature(e) {
    e.preventDefault()
    if (this.activeTab === 'draw') {
      this._ctx.clearRect(0, 0, this.canvasTarget.width, this.canvasTarget.height)
      this.hasDrawing = false
    } else {
      this.uploadInputTarget.value = ''
      this.previewTarget.src = ''
      this.previewTarget.classList.add('d-none')
    }
    // Reset the hidden file input so the existing attachment is preserved (no new file)
    this.fileInputTarget.value = ''
  }

  onUploadChange() {
    const file = this.uploadInputTarget.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (ev) => {
      this.previewTarget.src = ev.target.result
      this.previewTarget.classList.remove('d-none')
    }
    reader.readAsDataURL(file)

    // Copy the selected file to the real (hidden) input
    const dt = new DataTransfer()
    dt.items.add(file)
    this.fileInputTarget.files = dt.files
  }

  onFormSubmit(e) {
    // Se siamo sulla tab current, non toccare il file input (mantieni firma esistente)
    if (this.activeTab === 'current') return
    // Se siamo sulla tab upload, il file input è già popolato
    if (this.activeTab === 'upload') return
    // Tab draw: intercetta solo se l'utente ha disegnato qualcosa
    if (this._submitting) return
    if (!this.hasDrawing) return

    e.preventDefault()
    this._submitting = true

    this.canvasTarget.toBlob((blob) => {
      const file = new File([blob], 'signature.png', { type: 'image/png' })
      const dt = new DataTransfer()
      dt.items.add(file)
      this.fileInputTarget.files = dt.files
      this.hasDrawing = false
      this._submitting = false
      this._form.requestSubmit()
    }, 'image/png')
  }
}
