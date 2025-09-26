import { withPluginApi } from "discourse/lib/plugin-api";
import I18n from "I18n";
import { SIDEBAR_GROUPS_PANEL } from "../services/groups-sidebar";

export default {
  name: "groups-sidebar",
  initialize(container) {
    withPluginApi("1.34.0", (api) => {
      const groupsSidebar = container.lookup("service:groups-sidebar");
      const currentUser = container.lookup("service:current-user");
      const siteSettings = container.lookup("service:site-settings");

      const router = container.lookup("service:router");
      const groupsController = api.container.lookup("controller:groups");

      // groups panel
      api.addSidebarPanel((BaseCustomSidebarPanel) => {
        const GroupsSidebarPanel = class extends BaseCustomSidebarPanel {
          get hidden() {
            return false;
          }
          get key() {
            return SIDEBAR_GROUPS_PANEL;
          }
          get switchButtonLabel() {
            return "groups";
          }
          get switchButtonIcon() {
            return "users";
          }
          get switchButtonDefaultUrl() {
            return "/g";
          }
        };
        return GroupsSidebarPanel;
      });

      // groups navigation section
      api.addSidebarSection(
        (BaseCustomSidebarSection, BaseCustomSidebarSectionLink) => {
          const AllGroupsLink = class extends BaseCustomSidebarSectionLink {
            text = I18n.t("groups.index.all");
            title = I18n.t("groups.index.all");
            name = "all-groups";
            prefixType = "icon";
            prefixValue = "users";

            get href() {
              return "/g";
            }

            get currentWhen() {
              const currentURL = router.currentURL;
              return (
                currentURL === "/g" ||
                (currentURL?.startsWith("/g?") && !currentURL.includes("type="))
              );
            }
          };

          const OwnerGroupsLink = class extends BaseCustomSidebarSectionLink {
            route = "groups.index";
            text = I18n.t("groups.index.owner_groups");
            title = I18n.t("groups.index.owner_groups");
            name = "owner-groups";
            prefixType = "icon";
            prefixValue = "shield-halved";

            get query() {
              return { order: "name", type: "owner" };
            }
          };

          const AutomaticGroupsLink = class extends BaseCustomSidebarSectionLink {
            route = "groups.index";
            text = I18n.t("groups.index.automatic");
            title = I18n.t("groups.index.automatic");
            name = "automatic-groups";
            prefixType = "icon";
            prefixValue = "list-ol";

            get query() {
              return { order: "name", type: "automatic" };
            }
          };

          const PublicGroupsLink = class extends BaseCustomSidebarSectionLink {
            route = "groups.index";
            text = I18n.t("groups.index.public");
            title = I18n.t("groups.index.public");
            name = "public-groups";
            prefixType = "icon";
            prefixValue = "globe";

            get query() {
              return { order: "name", type: "public" };
            }
          };

          const CloseGroupsLink = class extends BaseCustomSidebarSectionLink {
            route = "groups.index";
            text = I18n.t("groups.index.close_groups");
            title = I18n.t("groups.index.close_groups");
            name = "close-groups";
            prefixType = "icon";
            prefixValue = "lock";

            get query() {
              return { order: "name", type: "close" };
            }
          };

          const GroupsNavigationSection = class extends BaseCustomSidebarSection {
            hideSectionHeader = false;
            name = "groups-navigation";

            get displaySection() {
              return true;
            }

            get sectionLinks() {
              const links = [
                new AllGroupsLink(),
                new OwnerGroupsLink(),
                new AutomaticGroupsLink(),
                new PublicGroupsLink(),
                new CloseGroupsLink(),
              ];

              return links;
            }

            get text() {
              return I18n.t("groups.index.title");
            }

            get links() {
              return this.sectionLinks;
            }
          };

          return GroupsNavigationSection;
        },
        SIDEBAR_GROUPS_PANEL
      );

      // user's groups section
      api.addSidebarSection(
        (BaseCustomSidebarSection, BaseCustomSidebarSectionLink) => {
          const createGroupLink = (group) => {
            return class extends BaseCustomSidebarSectionLink {
              route = "group.index";
              text = group.display_name || group.name;
              title = group.full_name || group.name;
              name = `group-${group.id}`;
              prefixType = "icon";
              prefixValue = "users";


              get model() {
                return group.name;
              }
            };
          };

          const UserGroupsSection = class extends BaseCustomSidebarSection {
            hideSectionHeader = false;
            name = "user-groups";

            get displaySection() {
              return currentUser?.groups?.length > 0;
            }

            get sectionLinks() {
              if (!currentUser?.groups) return [];

              return currentUser.groups.map((group) => {
                const GroupLink = createGroupLink(group);
                return new GroupLink();
              });
            }

            get text() {
              return I18n.t("groups.index.my_groups");
            }

            get links() {
              return this.sectionLinks;
            }
          };

          return UserGroupsSection;
        },
        SIDEBAR_GROUPS_PANEL
      );

    });
  },
};
