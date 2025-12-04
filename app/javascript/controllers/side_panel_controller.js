// app/javascript/controllers/side_panel_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "resizeHandle", "title"]
  static values = {
    initialWidth: Number
  }

  connect() {
    const width = this.initialWidthValue || 480
    this.panelTarget.style.width = `${width}px`

    this._onMouseMove = this._onMouseMove.bind(this)
    this._onMouseUp   = this._onMouseUp.bind(this)

    this.resizing = false
  }

  // リンクから呼ばれる
  // data-side-panel-title-param="..." でタイトルを受け取る
  open(event) {
    const title = event.params.title // side_panel_title_param → title

    if (this.hasTitleTarget && title) {
      this.titleTarget.textContent = title
    }

    this.panelTarget.classList.remove("translate-x-full")
    this.panelTarget.classList.add("translate-x-0")
  }

  close() {
    this.panelTarget.classList.add("translate-x-full")
    this.panelTarget.classList.remove("translate-x-0")
  }

  // リサイズ開始
  startResize(event) {
    event.preventDefault()
    this.resizing   = true
    this.startX     = event.clientX
    this.startWidth = this.panelTarget.getBoundingClientRect().width

    document.addEventListener("mousemove", this._onMouseMove)
    document.addEventListener("mouseup", this._onMouseUp)
  }

  _onMouseMove(event) {
    if (!this.resizing) return

    const deltaX = this.startX - event.clientX
    let newWidth = this.startWidth + deltaX

    const minWidth = 320
    const maxWidth = window.innerWidth - 100

    if (newWidth < minWidth) newWidth = minWidth
    if (newWidth > maxWidth) newWidth = maxWidth

    this.panelTarget.style.width = `${newWidth}px`
  }

  _onMouseUp() {
    this.resizing = false
    document.removeEventListener("mousemove", this._onMouseMove)
    document.removeEventListener("mouseup", this._onMouseUp)
  }
}
