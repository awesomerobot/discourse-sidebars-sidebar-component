import BaseSidebarService from "./base-sidebar";

export const SIDEBAR_INBOXES_PANEL = "discourse-sidebar-inboxes";

export default class InboxesSidebarService extends BaseSidebarService {
  panelKey = SIDEBAR_INBOXES_PANEL;
  eventHandlerName = "showInboxesSidebar";

  constructor() {
    super(...arguments);
    this.appEvents.on("page:changed", this, this.showInboxesSidebar);
  }

  shouldShow() {
    const currentURL = this.router.currentURL;
    return (
      currentURL?.includes("/messages/group/") ||
      currentURL?.match(/\/messages\/group-/)
    );
  }

  // Alias methods for backward compatibility
  hideInboxesSidebar() {
    return this.hideSidebar();
  }

  showInboxesSidebar() {
    return this.showSidebar();
  }
}
