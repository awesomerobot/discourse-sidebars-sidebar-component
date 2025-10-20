import { tracked } from "@glimmer/tracking";
import BaseSidebarService from "./base-sidebar";

export const SIDEBAR_USER_PANEL = "discourse-sidebar-user";

export default class UserSidebarService extends BaseSidebarService {
  panelKey = SIDEBAR_USER_PANEL;
  eventHandlerName = "showUserSidebar";

  @tracked _activeTopicId;

  constructor() {
    super(...arguments);
    this.appEvents.on("page:changed", this, this.showUserSidebar);
  }

  shouldShow() {
    return (
      this.router?.currentRouteName?.includes("user") ||
      this.router?.currentRouteName?.includes("preferences")
    );
  }

  hideUserSidebar() {
    return this.hideSidebar();
  }

  showUserSidebar() {
    return this.showSidebar();
  }
}
