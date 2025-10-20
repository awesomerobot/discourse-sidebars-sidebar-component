import { tracked } from "@glimmer/tracking";
import BaseSidebarService from "./base-sidebar";

export const SIDEBAR_GROUPS_PANEL = "discourse-sidebar-groups";

export default class GroupsSidebarService extends BaseSidebarService {
  panelKey = SIDEBAR_GROUPS_PANEL;
  eventHandlerName = "showGroupsSidebar";

  @tracked _activeGroupId;

  constructor() {
    super(...arguments);
    this.appEvents.on("page:changed", this, this.showGroupsSidebar);
  }

  shouldShow() {
    return (
      this.router.currentRouteName?.includes("groups") ||
      this.router.currentURL?.includes("/g/")
    );
  }

  // Alias methods for backward compatibility
  hideGroupsSidebar() {
    return this.hideSidebar();
  }

  showGroupsSidebar() {
    return this.showSidebar();
  }
}
