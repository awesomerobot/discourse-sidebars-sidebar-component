import BaseSidebarService from "./base-sidebar";

export const SIDEBAR_ABOUT_PANEL = "discourse-sidebar-about";

export default class AboutSidebarService extends BaseSidebarService {
  panelKey = SIDEBAR_ABOUT_PANEL;
  eventHandlerName = "showAboutSidebar";

  constructor() {
    super(...arguments);
    this.appEvents.on("page:changed", this, this.showAboutSidebar);
  }

  shouldShow() {
    const currentURL = this.router.currentURL;
    const isUsersDirectory =
      currentURL === "/u" || currentURL?.startsWith("/u?");

    return (
      (currentURL?.includes("/about") && !currentURL.includes("/ap/about")) ||
      currentURL?.includes("/faq") ||
      currentURL?.includes("/privacy") ||
      currentURL?.includes("/ap/about") ||
      (currentURL?.includes("/badges") && !currentURL.includes("/u/")) ||
      currentURL?.includes("/cakeday/anniversaries") ||
      currentURL?.includes("/cakeday/birthdays") ||
      currentURL?.includes("/leaderboard") ||
      isUsersDirectory
    );
  }

  // Alias methods for backward compatibility
  hideAboutSidebar() {
    return this.hideSidebar();
  }

  showAboutSidebar() {
    return this.showSidebar();
  }
}
