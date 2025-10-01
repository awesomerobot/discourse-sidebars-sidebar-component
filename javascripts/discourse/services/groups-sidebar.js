import { tracked } from "@glimmer/tracking";
import Service, { service } from "@ember/service";
import { MAIN_PANEL } from "discourse/lib/sidebar/panels";

export const SIDEBAR_GROUPS_PANEL = "discourse-sidebar-groups";

export default class GroupsSidebarService extends Service {
  @service appEvents;
  @service router;
  @service sidebarState;
  @service store;

  @tracked sidebarSettings = null;

  @tracked _activeGroupId;
  @tracked _currentSectionsConfig = null;
  @tracked _loading = false;

  constructor() {
    super(...arguments);
    this.appEvents.on("page:changed", this, this.showGroupsSidebar);
  }

  get isEnabled() {
    return true;
  }

  get isVisible() {
    return this.sidebarState?.currentPanel && this.sidebarState.isCurrentPanel(SIDEBAR_GROUPS_PANEL);
  }

  get loading() {
    return false;
  }

  hideGroupsSidebar() {
    if (!this.isVisible) {
      return;
    }

    this.sidebarState.setPanel(MAIN_PANEL);
  }

  showGroupsSidebar() {
    if (
      this.router.currentRouteName?.includes("groups") ||
      this.router.currentURL?.includes("/g/")
    ) {
      this.sidebarState.setPanel(SIDEBAR_GROUPS_PANEL);
      this.sidebarState.setSeparatedMode();
      this.sidebarState.hideSwitchPanelButtons();
    } else {
      this.hideGroupsSidebar();
    }
  }

  toggleSidebarPanel() {
    if (this.isVisible) {
      this.hideGroupsSidebar();
    } else {
      this.showGroupsSidebar();
    }
  }
}