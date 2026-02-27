import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const saved = localStorage.getItem("theme") || "dark"
    document.documentElement.setAttribute("data-theme", saved)
    this.updateIcon(saved)
  }

  toggle() {
    const current = document.documentElement.getAttribute("data-theme") || "dark"
    const next = current === "dark" ? "light" : "dark"
    document.documentElement.setAttribute("data-theme", next)
    localStorage.setItem("theme", next)
    this.updateIcon(next)
  }

  updateIcon(theme) {
    this.element.textContent = theme === "dark" ? "☀" : "◑"
  }
}
