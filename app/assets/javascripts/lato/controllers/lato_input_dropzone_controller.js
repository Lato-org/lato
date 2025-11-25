import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["input", "dropzone", "preview"]
  static values = {
    multiple: Boolean,
    directUpload: Boolean
  }

  connect() {
    this.files = []
    
    if (this.directUploadValue) {
      this.inputName = this.inputTarget.name
      this.inputTarget.removeAttribute('name')
    }

    // Initialize files from input if any (e.g. browser back button)
    if (this.inputTarget.files.length > 0) {
      this.handleFiles(this.inputTarget.files)
    }
  }

  onClick(e) {
    this.inputTarget.click()
  }

  onDragOver(e) {
    e.preventDefault()
    this.dropzoneTarget.classList.add("border-primary")
    this.dropzoneTarget.classList.remove("bg-light")
    this.dropzoneTarget.classList.add("bg-white")
  }

  onDragLeave(e) {
    e.preventDefault()
    this.dropzoneTarget.classList.remove("border-primary")
    this.dropzoneTarget.classList.add("bg-light")
    this.dropzoneTarget.classList.remove("bg-white")
  }

  onDrop(e) {
    e.preventDefault()
    this.dropzoneTarget.classList.remove("border-primary")
    this.dropzoneTarget.classList.add("bg-light")
    this.dropzoneTarget.classList.remove("bg-white")

    if (e.dataTransfer.files.length > 0) {
      this.handleFiles(e.dataTransfer.files)
    }
  }

  onInputChange(e) {
    if (this.inputTarget.files.length > 0) {
      // When input changes via dialog, we add these files.
      // Note: standard input behavior replaces files.
      // We treat the input selection as "new files to add" if multiple, or "replace" if single.
      // But since we can't easily distinguish "add" vs "replace" intent from a simple change event on the same input,
      // and the input itself only holds the new selection, we have to be careful.
      
      // Strategy:
      // 1. Read new files from input.
      // 2. Update our internal list.
      // 3. Update the input to reflect the FULL list (so form submit works for normal uploads).
      
      const newFiles = Array.from(this.inputTarget.files)
      this.handleFiles(newFiles)
    }
  }

  handleFiles(newFiles) {
    if (this.multipleValue) {
      // Filter duplicates if needed, or just add.
      // For simplicity, just add.
      this.files = [...this.files, ...newFiles]
    } else {
      this.files = newFiles
    }
    
    this.updateInput()
    this.updatePreview()
    
    if (this.directUploadValue) {
      this.uploadFiles(newFiles)
    }
  }

  updateInput() {
    const dataTransfer = new DataTransfer()
    this.files.forEach(file => dataTransfer.items.add(file))
    this.inputTarget.files = dataTransfer.files
  }

  updatePreview() {
    this.previewTarget.innerHTML = ""
    this.files.forEach((file, index) => {
      const fileElement = document.createElement("div")
      fileElement.classList.add("d-flex", "align-items-center", "justify-content-between", "p-2", "border", "rounded", "mb-2")
      
      const info = document.createElement("div")
      info.classList.add("d-flex", "align-items-center")
      
      const icon = document.createElement("i")
      icon.classList.add("bi", "bi-file-earmark", "fs-4", "me-2")
      
      const name = document.createElement("span")
      name.textContent = file.name
      name.classList.add("text-truncate")
      name.style.maxWidth = "200px"
      
      info.appendChild(icon)
      info.appendChild(name)
      
      const rightSide = document.createElement("div")
      rightSide.classList.add("d-flex", "align-items-center")

      // Progress bar container
      if (this.directUploadValue) {
        const progressContainer = document.createElement("div")
        progressContainer.classList.add("me-3")
        progressContainer.style.width = "100px"
        progressContainer.id = `upload-progress-${this.getFileId(file)}`
        progressContainer.style.display = "none"
        
        const progressBar = document.createElement("div")
        progressBar.classList.add("progress")
        progressBar.style.height = "5px"
        
        const progressBarInner = document.createElement("div")
        progressBarInner.classList.add("progress-bar")
        progressBarInner.role = "progressbar"
        progressBarInner.style.width = "0%"
        
        progressBar.appendChild(progressBarInner)
        progressContainer.appendChild(progressBar)
        rightSide.appendChild(progressContainer)
      }

      const removeBtn = document.createElement("button")
      removeBtn.type = "button"
      removeBtn.classList.add("btn", "btn-sm", "btn-outline-danger")
      removeBtn.innerHTML = '<i class="bi bi-x"></i>'
      removeBtn.onclick = (e) => {
        e.stopPropagation()
        this.removeFile(index)
      }
      
      rightSide.appendChild(removeBtn)
      fileElement.appendChild(info)
      fileElement.appendChild(rightSide)
      
      this.previewTarget.appendChild(fileElement)
    })
  }

  removeFile(index) {
    const file = this.files[index]
    
    if (this.directUploadValue) {
      const hiddenInput = this.element.querySelector(`input[type="hidden"][data-file-id="${this.getFileId(file)}"]`)
      if (hiddenInput) hiddenInput.remove()
    }

    this.files.splice(index, 1)
    this.updateInput()
    this.updatePreview()
  }

  getFileId(file) {
    return `${file.name.replace(/[^a-zA-Z0-9]/g, '')}-${file.lastModified}`
  }

  uploadFiles(files) {
    const url = this.inputTarget.dataset.directUploadUrl
    if (!url) return

    files.forEach(file => {
      const progressId = `upload-progress-${this.getFileId(file)}`
      
      const delegate = {
        directUploadWillStoreFileWithXHR: (request) => {
          request.upload.addEventListener("progress", (event) => {
            const element = document.getElementById(progressId)
            if (element) {
              element.style.display = "block"
              const progress = (event.loaded / event.total) * 100
              element.querySelector(".progress-bar").style.width = `${progress}%`
            }
          })
        }
      }
      
      const upload = new DirectUpload(file, url, delegate)
      
      upload.create((error, blob) => {
        if (error) {
          const element = document.getElementById(progressId)
          if (element) {
             element.querySelector(".progress-bar").classList.add("bg-danger")
          }
        } else {
          const element = document.getElementById(progressId)
          if (element) {
             element.querySelector(".progress-bar").classList.add("bg-success")
             
             const hiddenInput = document.createElement("input")
             hiddenInput.type = "hidden"
             hiddenInput.name = this.inputName
             hiddenInput.value = blob.signed_id
             hiddenInput.dataset.fileId = this.getFileId(file)
             this.element.appendChild(hiddenInput)
          }
        }
      })
    })
  }
}
