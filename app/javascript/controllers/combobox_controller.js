import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown", "option", "hiddenInput", "form"]

  connect() {
    this._outsideClick = e => { if (!this.element.contains(e.target)) this.close() }
    document.addEventListener("click", this._outsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this._outsideClick)
  }

  open() {
    this.#showAll()
    this.dropdownTarget.hidden = false
  }

  close() {
    this.dropdownTarget.hidden = true
  }

  filter() {
    this.dropdownTarget.hidden = false
    const q = this.inputTarget.value.toLowerCase()
    this.optionTargets.forEach(opt => {
      opt.hidden = q.length > 0 && !opt.textContent.trim().toLowerCase().includes(q)
    })
  }

  select(event) {
    event.stopPropagation()
    const opt = event.currentTarget
    this.#applySelection(opt.dataset.value, opt.textContent.trim())
  }

  inputKeydown(event) {
    if (event.key === "Escape") { this.close(); return }
    if (event.key === "ArrowDown") {
      event.preventDefault()
      const first = this.optionTargets.find(o => !o.hidden)
      first?.focus()
    }
  }

  optionKeydown(event) {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault()
      this.#applySelection(event.currentTarget.dataset.value, event.currentTarget.textContent.trim())
    } else if (event.key === "ArrowDown") {
      event.preventDefault()
      this.#shiftFocus(event.currentTarget, 1)
    } else if (event.key === "ArrowUp") {
      event.preventDefault()
      this.#shiftFocus(event.currentTarget, -1)
    } else if (event.key === "Escape") {
      this.close()
      this.inputTarget.focus()
    }
  }

  // ── Private ──────────────────────────────────────────────────────────────

  #applySelection(value, label) {
    this.hiddenInputTarget.value = value
    this.inputTarget.value = value === "" ? "" : label
    this.close()
    this.formTarget.requestSubmit()
  }

  #showAll() {
    this.optionTargets.forEach(o => { o.hidden = false })
  }

  #shiftFocus(current, dir) {
    const visible = this.optionTargets.filter(o => !o.hidden)
    const idx = visible.indexOf(current)
    const next = visible[idx + dir]
    if (next) next.focus()
    else if (dir < 0) this.inputTarget.focus()
  }
}
