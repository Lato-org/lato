import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "listItem", "template"]

  addItem() {
    const template = this.templateTarget
    const nextIndex = this.getNextIndex()
    const newItem = template.content.cloneNode(true)
    newItem.querySelector('.template').setAttribute('data-lato-input-list-target', 'listItem')
    newItem.querySelector('.template').setAttribute('data-index', nextIndex)
    newItem.querySelector('.template').classList.remove('template')
    
    this.updateFieldNames(newItem, nextIndex)
    this.listTarget.appendChild(newItem)
  }

  removeItem(event) {
    const item = event.target.closest('[data-lato-input-list-target="listItem"]')
    if (!item) return

    const existingDestroyField = item.querySelector('input[type="hidden"][name*="[_destroy]"]')
    if (existingDestroyField) return

    const hiddenIdField = item.querySelector('input[type="hidden"][name*="[id]"]')
    if (hiddenIdField && hiddenIdField.value) {
      const destroyField = document.createElement('input')
      destroyField.type = 'hidden'
      destroyField.name = hiddenIdField.name.replace('[id]', '[_destroy]')
      destroyField.value = '1'
      item.appendChild(destroyField)
      
      item.style.display = 'none'
      item.classList.add('d-none')
      
      const inputs = item.querySelectorAll('input, select, textarea')
      inputs.forEach(input => {
        if (input.type !== 'hidden') input.disabled = true
      })
    } else {
      item.remove()
    }
  }

  updateFieldNames(element, index) {
    const inputs = element.querySelectorAll('input, select, textarea')
    const labels = element.querySelectorAll('label')
    
    inputs.forEach(input => {
      if (input.name) {
        input.name = input.name.replace('0', index)
      }
      
      if (input.id) {
        input.id = input.id.replace('0', index)
      }
    })
    
    labels.forEach(label => {
      if (label.getAttribute('for')) {
        label.setAttribute('for', label.getAttribute('for').replace('0', index))
      }
    })
  }

  getNextIndex() {
    const itemsIndicies = Array.from(this.listItemTargets).map(item => {
      const indexAttr = item.getAttribute('data-index')
      return indexAttr ? parseInt(indexAttr, 10) : -1
    })
    const maxIndex = itemsIndicies.length > 0 ? Math.max(...itemsIndicies) : -1
    return maxIndex + 1
  }
}