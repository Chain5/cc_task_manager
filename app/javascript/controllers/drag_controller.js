import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  dragStart(event) {
    event.dataTransfer.setData("text/plain", event.currentTarget.dataset.taskId)
    event.dataTransfer.effectAllowed = "move"
    event.currentTarget.classList.add("is-dragging")
    this.element.classList.add("is-dragging")
  }

  dragEnd(event) {
    event.currentTarget.classList.remove("is-dragging")
    this.element.classList.remove("is-dragging")
  }

  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
    event.currentTarget.classList.add("drag-over")
  }

  dragLeave(event) {
    if (!event.currentTarget.contains(event.relatedTarget)) {
      event.currentTarget.classList.remove("drag-over")
    }
  }

  cardClick(event) {
    // Ignore if the click landed on a link or button inside the card
    if (event.target.closest("a, button")) return
    window.Turbo.visit(event.currentTarget.dataset.url)
  }

  drop(event) {
    event.preventDefault()
    const column = event.currentTarget
    column.classList.remove("drag-over")

    const taskId = event.dataTransfer.getData("text/plain")
    const newStatus = column.dataset.status
    if (!taskId || !newStatus) return

    fetch(`/tasks/${taskId}/move`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ status: newStatus })
    }).then(response => {
      if (response.ok) {
        window.Turbo.visit(window.location.href, { action: "replace" })
      }
    })
  }
}
