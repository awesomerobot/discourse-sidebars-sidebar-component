import { tracked } from "@glimmer/tracking";
import Service, { service } from "@ember/service";
import { MAIN_PANEL } from "discourse/lib/sidebar/panels";

export const SIDEBAR_ABOUT_PANEL = "discourse-sidebar-about";

export default class AboutSidebarService extends Service {
  @service appEvents;
  @service router;
  @service sidebarState;
  @service store;

  @tracked sidebarSettings = null;

  @tracked _currentSectionsConfig = null;
  @tracked _loading = false;

  constructor() {
    super(...arguments);
    this.appEvents.on("page:changed", this, this.showAboutSidebar);
  }

  get isEnabled() {
    return true;
  }

  get isVisible() {
    return this.sidebarState.isCurrentPanel(SIDEBAR_ABOUT_PANEL);
  }

  get loading() {
    return false;
  }

  hideAboutSidebar() {
    if (!this.isVisible) {
      return;
    }

    this.sidebarState.setPanel(MAIN_PANEL);
  }

  showAboutSidebar() {
    const currentURL = this.router.currentURL;
    const isUsersDirectory = currentURL === "/u" || currentURL?.startsWith("/u?");

    if (
      currentURL?.includes("/about") ||
      currentURL?.includes("/faq") ||
      currentURL?.includes("/privacy") ||
      currentURL?.includes("/badges") ||
      isUsersDirectory
    ) {
      this.sidebarState.setPanel(SIDEBAR_ABOUT_PANEL);
      this.sidebarState.setSeparatedMode();
      this.sidebarState.hideSwitchPanelButtons();
    } else {
      this.hideAboutSidebar();
    }
  }

  toggleSidebarPanel() {
    if (this.isVisible) {
      this.hideAboutSidebar();
    } else {
      this.showAboutSidebar();
    }
  }
}
