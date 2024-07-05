import { tracked } from "@glimmer/tracking";
import Service, { inject as service } from "@ember/service";
import { MAIN_PANEL } from "discourse/lib/sidebar/panels";

export const SIDEBAR_USER_PANEL = "discourse-sidebar-user";

export default class UserSidebarService extends Service {
  @service appEvents;
  @service router;
  @service sidebarState;
  @service store;

  @tracked sidebarSettings = null;

  @tracked _activeTopicId;
  @tracked _currentSectionsConfig = null;
  @tracked _loading = false;

  constructor() {
    super(...arguments);
    this.appEvents.on("page:changed", this, this.showUserSidebar);
  }

  get isEnabled() {
    return true;
  }

  get isVisible() {
    return this.sidebarState.isCurrentPanel(SIDEBAR_USER_PANEL);
  }

  get loading() {
    return false;
  }

  hideUserSidebar() {
    if (!this.isVisible) {
      return;
    }

    this.sidebarState.setPanel(MAIN_PANEL);
  }

  showUserSidebar() {
    console.log(this.router.currentRouteName);
    if (
      this.router.currentRouteName.includes("user") ||
      this.router.currentRouteName.includes("preferences")
    ) {
      this.sidebarState.setPanel(SIDEBAR_USER_PANEL);
      this.sidebarState.setSeparatedMode();
      this.sidebarState.hideSwitchPanelButtons();
    } else {
      this.hideUserSidebar();
    }
  }

  toggleSidebarPanel() {
    if (this.isVisible) {
      this.hideUserSidebar();
    } else {
      this.showUserSidebar();
    }
  }
}
