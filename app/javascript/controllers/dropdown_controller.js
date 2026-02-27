import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle(event) {
    // Stop the click from bubbling to the window listener so it doesn't
    // immediately re-close the menu we just opened.
    event.stopPropagation()
    this.menuTarget.classList.toggle("is-open")
  }

  close() {
    this.menuTarget.classList.remove("is-open")
  }
}
