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

  open(event) {
    // 1. タイトルの更新
    const title = event.params.title
    if (this.hasTitleTarget && title) {
      this.titleTarget.textContent = title
    }

    // 2. hidden を解除（これで DOM 上にスペースが確保される）
    this.panelTarget.classList.remove("hidden")

    // 3. ブラウザの描画を待ってからアニメーションを開始
    requestAnimationFrame(() => {
      this.panelTarget.classList.remove("translate-x-full")
      this.panelTarget.classList.add("translate-x-0")
    })
  }

  close() {
    // 1. 画面外へ戻すアニメーションを開始
    this.panelTarget.classList.add("translate-x-full")
    this.panelTarget.classList.remove("translate-x-0")

    // 2. アニメーション（duration-200）が終わってから hidden にする
    // これをしないと、閉じた後も「透明な壁」が右側に残ってしまいます
    setTimeout(() => {
      this.panelTarget.classList.add("hidden")
    }, 200) 
  }

  // --- リサイズ機能はそのまま維持 ---
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
