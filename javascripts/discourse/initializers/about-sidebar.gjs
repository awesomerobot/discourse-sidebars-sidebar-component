import { withPluginApi } from "discourse/lib/plugin-api";
import I18n from "I18n";
import { SIDEBAR_ABOUT_PANEL } from "../services/about-sidebar";

export default {
  name: "about-sidebar",
  initialize(container) {
    withPluginApi("1.34.0", (api) => {
      const aboutSidebar = container.lookup("service:about-sidebar");
      const currentUser = container.lookup("service:current-user");
      const siteSettings = container.lookup("service:site-settings");

      // about panel
      api.addSidebarPanel((BaseCustomSidebarPanel) => {
        const AboutSidebarPanel = class extends BaseCustomSidebarPanel {
          get hidden() {
            return false;
          }
          get key() {
            return SIDEBAR_ABOUT_PANEL;
          }
          get switchButtonLabel() {
            return "about";
          }
          get switchButtonIcon() {
            return "info-circle";
          }
          get switchButtonDefaultUrl() {
            return "/about";
          }
        };
        return AboutSidebarPanel;
      });

      // site information section
      api.addSidebarSection(
        (BaseCustomSidebarSection, BaseCustomSidebarSectionLink) => {
          const AboutLink = class extends BaseCustomSidebarSectionLink {
            text = "About";
            title = "About";
            name = "about";
            prefixType = "icon";
            prefixValue = "circle-info";

            get href() {
              return "/about";
            }

            get currentWhen() {
              const router = container.lookup("service:router");
              return (
                router.currentURL?.includes("/about") &&
                !router.currentURL?.includes("/ap/about")
              );
            }
          };

          const FAQLink = class extends BaseCustomSidebarSectionLink {
            text = "FAQ";
            title = "FAQ";
            name = "faq";
            prefixType = "icon";
            prefixValue = "circle-question";

            get href() {
              return "/faq";
            }

            get currentWhen() {
              const router = container.lookup("service:router");
              return router.currentURL?.includes("/faq");
            }
          };

          const PrivacyLink = class extends BaseCustomSidebarSectionLink {
            text = "Privacy";
            title = "Privacy";
            name = "privacy";
            prefixType = "icon";
            prefixValue = "fingerprint";

            get href() {
              return "/privacy";
            }

            get currentWhen() {
              const router = container.lookup("service:router");
              return router.currentURL?.includes("/privacy");
            }
          };

          const ActivityPubLink = class extends BaseCustomSidebarSectionLink {
            text = "ActivityPub";
            title = "ActivityPub";
            name = "activitypub";
            prefixType = "icon";
            prefixValue = "share-nodes";

            get href() {
              return "/ap/about";
            }

            get currentWhen() {
              const router = container.lookup("service:router");
              return router.currentURL?.includes("/ap/about");
            }
          };

          const SiteInfoSection = class extends BaseCustomSidebarSection {
            hideSectionHeader = false;
            name = "site-info";

            get displaySection() {
              return true;
            }

            get sectionLinks() {
              const links = [new AboutLink(), new FAQLink(), new PrivacyLink()];

              if (siteSettings.activity_pub_enabled) {
                links.push(new ActivityPubLink());
              }

              return links;
            }

            get text() {
              return "Site Info";
            }

            get links() {
              return this.sectionLinks;
            }
          };

          return SiteInfoSection;
        },
        SIDEBAR_ABOUT_PANEL
      );

      // community section
      api.addSidebarSection(
        (BaseCustomSidebarSection, BaseCustomSidebarSectionLink) => {
          const BadgesLink = class extends BaseCustomSidebarSectionLink {
            text = "Badges";
            title = "Badges";
            name = "badges";
            prefixType = "icon";
            prefixValue = "certificate";

            get href() {
              return "/badges";
            }

            get currentWhen() {
              const router = container.lookup("service:router");
              return router.currentURL?.includes("/badges");
            }
          };

          const UsersLink = class extends BaseCustomSidebarSectionLink {
            text = "Users";
            title = "Users";
            name = "users";
            prefixType = "icon";
            prefixValue = "users";

            get href() {
              return "/u";
            }

            get currentWhen() {
              const router = container.lookup("service:router");
              const currentURL = router.currentURL;
              return currentURL === "/u" || currentURL?.startsWith("/u?");
            }
          };

          const AnniversariesLink = class extends BaseCustomSidebarSectionLink {
            text = I18n.t("anniversaries.title");
            title = I18n.t("anniversaries.title");
            name = "anniversaries";
            prefixType = "icon";
            prefixValue = "cake-candles";

            get href() {
              return "/cakeday/anniversaries/today";
            }

            get currentWhen() {
              const router = container.lookup("service:router");
              return router.currentURL?.includes("/cakeday/anniversaries");
            }
          };

          const BirthdaysLink = class extends BaseCustomSidebarSectionLink {
            text = I18n.t("birthdays.title");
            title = I18n.t("birthdays.title");
            name = "birthdays";
            prefixType = "icon";
            prefixValue = "cake-candles";

            get href() {
              return "/cakeday/birthdays/today";
            }

            get currentWhen() {
              const router = container.lookup("service:router");
              return router.currentURL?.includes("/cakeday/birthdays");
            }
          };

          const LeaderboardLink = class extends BaseCustomSidebarSectionLink {
            text = I18n.t("gamification.leaderboard.title");
            title = I18n.t("gamification.leaderboard.title");
            name = "leaderboard";
            prefixType = "icon";
            prefixValue = "trophy";

            get href() {
              return "/leaderboard";
            }

            get currentWhen() {
              const router = container.lookup("service:router");
              return router.currentURL?.includes("/leaderboard");
            }
          };

          const CommunitySection = class extends BaseCustomSidebarSection {
            hideSectionHeader = false;
            name = "community";

            get displaySection() {
              return true;
            }

            get sectionLinks() {
              const links = [];

              if (siteSettings.discourse_gamification_enabled) {
                links.push(new LeaderboardLink());
              }

              if (siteSettings.enable_badges) {
                links.push(new BadgesLink());
              }

              links.push(new UsersLink());

              if (siteSettings.cakeday_enabled) {
                links.push(new AnniversariesLink());
                links.push(new BirthdaysLink());
              }

              return links;
            }

            get text() {
              return "Community";
            }

            get links() {
              return this.sectionLinks;
            }
          };

          return CommunitySection;
        },
        SIDEBAR_ABOUT_PANEL
      );
    });
  },
};
