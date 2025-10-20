import { tracked } from "@glimmer/tracking";
import Service, { service } from "@ember/service";
import { MAIN_PANEL } from "discourse/lib/sidebar/panels";

export default class BaseSidebarService extends Service {
  @service appEvents;
  @service router;
  @service sidebarState;
  @service store;

  @tracked sidebarSettings = null;
  @tracked _currentSectionsConfig = null;
  @tracked _loading = false;

  willDestroy() {
    super.willDestroy();
    if (this.eventHandlerName) {
      this.appEvents.off("page:changed", this, this[this.eventHandlerName]);
    }
  }

  get isEnabled() {
    return true;
  }

  get isVisible() {
    return (
      this.sidebarState?.currentPanel &&
      this.sidebarState.isCurrentPanel(this.panelKey)
    );
  }

  get loading() {
    return false;
  }

  hideSidebar() {
    if (!this.isVisible) {
      return;
    }

    this.sidebarState.setPanel(MAIN_PANEL);
  }

  showSidebar() {
    if (this.shouldShow()) {
      this.sidebarState.setPanel(this.panelKey);
      this.sidebarState.setSeparatedMode();
      this.sidebarState.hideSwitchPanelButtons();
    } else {
      this.hideSidebar();
    }
  }

  toggleSidebarPanel() {
    if (this.isVisible) {
      this.hideSidebar();
    } else {
      this.showSidebar();
    }
  }

  shouldShow() {
    throw new Error("Subclass must implement shouldShow() method");
  }
}
