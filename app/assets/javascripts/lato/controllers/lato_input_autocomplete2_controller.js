import { Controller } from "@hotwired/stimulus"
import _ from 'lodash'

export default class extends Controller {
  static values = {
    path: String
  }

  /**
   * Stimulus
   */

  connect() {
    this.search = _.debounce(this.search, 500)

    this.realInput = document.createElement('input')
    this.realInput.type = 'hidden'
    this.realInput.name = this.element.getAttribute('name')
    this.realInput.value = this.element.value
    this.element.insertAdjacentElement('afterend', this.realInput)

    if (this.element.value) {
      this.setDefaultElementValue()
    }

    this.element.addEventListener('keyup', (e) => {
      this.search(e.target.value)
    })

    window.addEventListener('click', this.onWindowClick.bind(this))
    window.addEventListener('scroll', this.onWindowScroll.bind(this))
    window.addEventListener('resize', this.onWindowResize.bind(this))
  }

  disconnect() {
    this.realInput.remove()
    this.suggestHide()

    window.removeEventListener('click', this.onWindowClick.bind(this))
    window.removeEventListener('scroll', this.onWindowScroll.bind(this))
    window.removeEventListener('resize', this.onWindowResize.bind(this))
  }

  async search(value) {
    this.realInput.value = ''
    if (!value) return

    try {
      this.suggestShowLoading()
      setTimeout(async () => {
        const url = new URL(this.pathValue, window.location.origin)
        url.searchParams.append('q', value)
        const response = await fetch(url)
        const data = await response.json()
        this.suggestShow(data)
      }, 500)
    } catch (err) {
      console.error(err)
    }
  }

  suggestShowLoading() {
    if (this.optionsList) this.optionsList.remove()
    this.optionsList = document.createElement('ul')
    this.optionsList.classList.add('list-group')
    this.optionsList.style.position = 'fixed'
    this.optionsList.style.width = this.element.offsetWidth + 'px'
    this.optionsList.style.maxHeight = '200px'
    this.optionsList.style.overflowY = 'auto'
    this.optionsList.style.zIndex = 9999

    const elementRect = this.element.getBoundingClientRect()
    this.optionsList.style.top = elementRect.bottom + 'px'
    this.optionsList.style.left = elementRect.left + 'px'

    const li = document.createElement('li')
    li.classList.add('list-group-item')
    li.classList.add('text-muted')
    li.classList.add('text-center')
    li.innerHTML = '<span class="lato-spin d-inline-block"><i class="bi bi-arrow-clockwise"></i></span>'
    this.optionsList.appendChild(li)

    document.body.appendChild(this.optionsList)
  }

  suggestShow(data = []) {
    if (this.optionsList) this.optionsList.remove()
    this.optionsList = document.createElement('ul')
    this.optionsList.classList.add('list-group', 'border')
    this.optionsList.style.position = 'fixed'
    this.optionsList.style.width = this.element.offsetWidth + 'px'
    this.optionsList.style.maxHeight = '200px'
    this.optionsList.style.overflowY = 'auto'
    this.optionsList.style.zIndex = 9999

    const elementRect = this.element.getBoundingClientRect()
    this.optionsList.style.top = elementRect.bottom + 'px'
    this.optionsList.style.left = elementRect.left + 'px'

    if (data.length > 0) {
      data.forEach((option) => {
        const li = document.createElement('li')
        li.classList.add('list-group-item')
        li.classList.add('list-group-item-action')
        li.style.cursor = 'pointer'
        li.innerText = typeof option == 'string' ? option : option.label
        li.addEventListener('click', () => {
          this.element.value = typeof option == 'string' ? option : option.label
          this.realInput.value = typeof option == 'string' ? option : option.value
          this.suggestHide()
        })
        this.optionsList.appendChild(li)
      })
    } else {
      const li = document.createElement('li')
      li.classList.add('list-group-item')
      li.classList.add('text-muted')
      li.classList.add('text-center')
      li.innerText = 'No results found'
      this.optionsList.appendChild(li)
    }

    document.body.appendChild(this.optionsList)
  }

  suggestHide() {
    if (this.optionsList) this.optionsList.remove()
  }

  suggestReposition() {
    if (!this.optionsList) return

    const elementRect = this.element.getBoundingClientRect()
    this.optionsList.style.top = elementRect.bottom + 'px'
    this.optionsList.style.left = elementRect.left + 'px'
  }

  async setDefaultElementValue() {
    try {
      const url = new URL(this.pathValue, window.location.origin)
      url.searchParams.append('value', this.element.value)
      const response = await fetch(url)
      const data = await response.json()
      this.element.value = data?.label || this.element.value
    } catch (err) {
      console.error(err)
    }
  }

  onWindowClick(event) {
    if (!this.element.contains(event.target)) {
      this.suggestHide()
    }
  }

  onWindowScroll(event) {
    this.suggestReposition()
  }

  onWindowResize(event) {
    this.suggestReposition()
  }
}
