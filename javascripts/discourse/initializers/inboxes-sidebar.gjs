import { service } from "@ember/service";
import { withPluginApi } from "discourse/lib/plugin-api";
import { i18n } from "discourse-i18n";
import { SIDEBAR_INBOXES_PANEL } from "../services/inboxes-sidebar";

export default {
  name: "inboxes-sidebar",
  initialize(container) {
    withPluginApi("1.34.0", (api) => {
      const currentUser = container.lookup("service:current-user");

      // inboxes panel
      api.addSidebarPanel((BaseCustomSidebarPanel) => {
        const InboxesSidebarPanel = class extends BaseCustomSidebarPanel {
          get hidden() {
            return false;
          }
          get key() {
            return SIDEBAR_INBOXES_PANEL;
          }
          get switchButtonLabel() {
            return "inboxes";
          }
          get switchButtonIcon() {
            return "inbox";
          }
          get switchButtonDefaultUrl() {
            if (currentUser.groupsWithMessages?.length > 0) {
              const firstGroup = currentUser.groupsWithMessages[0];
              return `/u/${currentUser.username}/messages/group/${firstGroup.name}`;
            }
            return "/";
          }
        };
        return InboxesSidebarPanel;
      });

      // Create a section for each group inbox
      currentUser.groupsWithMessages?.forEach((group) => {
        api.addSidebarSection(
          (BaseCustomSidebarSection, BaseCustomSidebarSectionLink) => {
            const InboxLink = class extends BaseCustomSidebarSectionLink {
              @service pmTopicTrackingState;
              @service currentUser;
              name = `${group.name}-inbox`;
              prefixType = "icon";
              prefixValue = "inbox";

              get text() {
                return i18n("user.messages.inbox");
              }

              get title() {
                return i18n("user.messages.inbox");
              }

              get href() {
                return `/u/${this.currentUser.username}/messages/group/${group.name}`;
              }

              get suffixType() {
                if (this.badgeText || this.suffixValue) {
                  return "icon";
                }
              }

              get suffixValue() {
                const count =
                  this.pmTopicTrackingState.lookupCount("new", {
                    inboxFilter: "group",
                    groupName: group.name,
                  }) +
                  this.pmTopicTrackingState.lookupCount("unread", {
                    inboxFilter: "group",
                    groupName: group.name,
                  });
                if (!this.currentUser.sidebarShowCountOfNewItems && count > 0) {
                  return "circle";
                }
              }

              get suffixCSSClass() {
                return "unread";
              }

              get badgeText() {
                if (this.currentUser.sidebarShowCountOfNewItems) {
                  const count =
                    this.pmTopicTrackingState.lookupCount("new", {
                      inboxFilter: "group",
                      groupName: group.name,
                    }) +
                    this.pmTopicTrackingState.lookupCount("unread", {
                      inboxFilter: "group",
                      groupName: group.name,
                    });
                  return count > 0 ? count : null;
                }
              }
            };

            const NewLink = class extends BaseCustomSidebarSectionLink {
              @service pmTopicTrackingState;
              @service currentUser;

              name = `${group.name}-new`;
              prefixType = "icon";
              prefixValue = "discourse-sparkles";

              get text() {
                return i18n("user.messages.new");
              }

              get title() {
                return i18n("user.messages.new");
              }

              get href() {
                return `/u/${this.currentUser.username}/messages/group/${group.name}/new`;
              }

              get suffixType() {
                if (this.badgeText || this.suffixValue) {
                  return "icon";
                }
              }

              get suffixValue() {
                const count = this.pmTopicTrackingState.lookupCount("new", {
                  inboxFilter: "group",
                  groupName: group.name,
                });
                if (!this.currentUser.sidebarShowCountOfNewItems && count > 0) {
                  return "circle";
                }
              }

              get suffixCSSClass() {
                return "unread";
              }

              get badgeText() {
                if (this.currentUser.sidebarShowCountOfNewItems) {
                  const count = this.pmTopicTrackingState.lookupCount("new", {
                    inboxFilter: "group",
                    groupName: group.name,
                  });
                  return count > 0 ? count : null;
                }
              }
            };

            const UnreadLink = class extends BaseCustomSidebarSectionLink {
              @service pmTopicTrackingState;
              @service currentUser;

              name = `${group.name}-unread`;
              prefixType = "icon";
              prefixValue = "envelope";

              get text() {
                return i18n("user.messages.unread");
              }

              get title() {
                return i18n("user.messages.unread");
              }

              get href() {
                return `/u/${this.currentUser.username}/messages/group/${group.name}/unread`;
              }

              get suffixType() {
                if (this.badgeText || this.suffixValue) {
                  return "icon";
                }
              }

              get suffixValue() {
                const count = this.pmTopicTrackingState.lookupCount("unread", {
                  inboxFilter: "group",
                  groupName: group.name,
                });
                if (!this.currentUser.sidebarShowCountOfNewItems && count > 0) {
                  return "circle";
                }
              }

              get suffixCSSClass() {
                return "unread";
              }

              get badgeText() {
                if (this.currentUser.sidebarShowCountOfNewItems) {
                  const count = this.pmTopicTrackingState.lookupCount("unread", {
                    inboxFilter: "group",
                    groupName: group.name,
                  });
                  return count > 0 ? count : null;
                }
              }
            };

            const ArchiveLink = class extends BaseCustomSidebarSectionLink {
              @service currentUser;

              name = `${group.name}-archive`;
              prefixType = "icon";
              prefixValue = "box-archive";

              get text() {
                return i18n("user.messages.archive");
              }

              get title() {
                return i18n("user.messages.archive");
              }

              get href() {
                return `/u/${this.currentUser.username}/messages/group/${group.name}/archive`;
              }
            };

            const GroupInboxSection = class extends BaseCustomSidebarSection {
              hideSectionHeader = false;
              name = `group-inbox-${group.name}`;

              get displaySection() {
                return true;
              }

              get sectionLinks() {
                return [
                  new InboxLink(),
                  new NewLink(),
                  new UnreadLink(),
                  new ArchiveLink(),
                ];
              }

              get text() {
                return group.name;
              }

              get links() {
                return this.sectionLinks;
              }
            };

            return GroupInboxSection;
          },
          SIDEBAR_INBOXES_PANEL
        );
      });
    });
  },
};
