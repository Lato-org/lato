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
    this.datalist = document.createElement('datalist')
    this.datalist.id = Math.random().toString(36)
    this.element.setAttribute('list', this.datalist.id)
    this.element.parentNode.appendChild(this.datalist)

    this.element.addEventListener('keyup', (e) => {
      this.search(e.target.value)
    })
  }

  async search(value) {
    if (!value || value.length < 3) return this.clear()

    try {
      const response = await fetch(this.pathValue + '?q=' + value)
      const data = await response.json()
      this.suggest(data)
    } catch (err) {
      console.error(err)
      this.clear()
    }
  }

  suggest(data = []) {
    this.clear()

    data.forEach((item) => {
      const option = document.createElement('option')
      option.value = typeof item === 'string' ? item : item.label
      this.datalist.appendChild(option)
    })
  }

  clear() {
    this.datalist.innerHTML = ''
  }
};
