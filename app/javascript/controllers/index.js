// app/javascript/controllers/index.js
import { Application } from "@hotwired/stimulus"
import SidePanelController from "./side_panel_controller"

const application = Application.start()

application.register("side-panel", SidePanelController)