import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "dropzone", "uploadBtn", "input",
    "preview", "placeholder",
    "urlInput"
  ]

  // ── File picker ───────────────────────────────────────────────────────────

  openPicker() {
    this.inputTarget.click()
  }

  fileChosen(event) {
    const file = event.target.files[0]
    if (file) this.#handleFile(file)
  }

  // ── Drag & drop ───────────────────────────────────────────────────────────

  dragOver(event) {
    event.preventDefault()
    if (!this.dropzoneTarget.classList.contains("is-disabled")) {
      this.dropzoneTarget.classList.add("is-dragover")
    }
  }

  dragLeave(event) {
    if (!this.dropzoneTarget.contains(event.relatedTarget)) {
      this.dropzoneTarget.classList.remove("is-dragover")
    }
  }

  drop(event) {
    event.preventDefault()
    this.dropzoneTarget.classList.remove("is-dragover")
    if (this.dropzoneTarget.classList.contains("is-disabled")) return

    const file = event.dataTransfer.files[0]
    if (!file || !file.type.startsWith("image/")) return

    const dt = new DataTransfer()
    dt.items.add(file)
    this.inputTarget.files = dt.files
    this.#handleFile(file)
  }

  // ── URL field ─────────────────────────────────────────────────────────────

  urlTyped() {
    const hasUrl = this.urlInputTarget.value.trim().length > 0
    // Disable the upload zone while a URL is entered
    this.dropzoneTarget.classList.toggle("is-disabled", hasUrl)
    this.uploadBtnTarget.disabled = hasUrl
    if (hasUrl) {
      // Clear any pending file selection
      this.inputTarget.value = ""
      this.#hidePreview()
    }
  }

  // ── Private ───────────────────────────────────────────────────────────────

  #handleFile(file) {
    // Clear and disable the URL field
    this.urlInputTarget.value    = ""
    this.urlInputTarget.disabled = true

    const reader = new FileReader()
    reader.onload = (e) => {
      this.previewTarget.src          = e.target.result
      this.previewTarget.hidden       = false
      this.placeholderTarget.hidden   = true
    }
    reader.readAsDataURL(file)
  }

  #hidePreview() {
    this.previewTarget.hidden     = true
    this.previewTarget.src        = ""
    this.placeholderTarget.hidden = false
  }
}
