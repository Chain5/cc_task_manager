import "@hotwired/turbo-rails"
import "controllers"

// ── Custom confirm dialog ──────────────────────────
const confirmFn = (message) => new Promise((resolve) => {
  const dialog = document.getElementById("tm-confirm")
  if (!dialog) return resolve(window.confirm(message))

  document.getElementById("tm-confirm-msg").textContent = message
  dialog.classList.add("is-open")

  const done = (result) => {
    dialog.classList.remove("is-open")
    resolve(result)
  }

  document.getElementById("tm-confirm-ok")
    .addEventListener("click", () => done(true),  { once: true })
  document.getElementById("tm-confirm-cancel")
    .addEventListener("click", () => done(false), { once: true })
})

// Turbo 7 uses setConfirmMethod; Turbo 8 uses config.forms.confirm
typeof Turbo.setConfirmMethod === "function"
  ? Turbo.setConfirmMethod(confirmFn)
  : (Turbo.config.forms.confirm = confirmFn)
