import { withPluginApi } from "discourse/lib/plugin-api";
import I18n from "I18n";
import { SIDEBAR_USER_PANEL } from "../services/user-sidebar";

export default {
  name: "user-sidebar",
  initialize(container) {
    withPluginApi("1.34.0", (api) => {
      const userSidebar = container.lookup("service:user-sidebar");
      const currentUser = container.lookup("service:current-user");
      const siteSettings = container.lookup("service:site-settings");

      const router = container.lookup("service:router");
      const userController = api.container.lookup("controller:user");

      // user panel
      api.addSidebarPanel((BaseCustomSidebarPanel) => {
        const UserSidebarPanel = class extends BaseCustomSidebarPanel {
          get hidden() {
            return false;
          }
          get key() {
            return SIDEBAR_USER_PANEL;
          }
          get switchButtonLabel() {
            return "user";
          }
          get switchButtonIcon() {
            return "user";
          }
          get switchButtonDefaultUrl() {
            return "/my/summary";
          }
        };
        return UserSidebarPanel;
      });

      // user summary section
      api.addSidebarSection(
        (BaseCustomSidebarSection, BaseCustomSidebarSectionLink) => {
          const UserSummaryLink = class extends BaseCustomSidebarSectionLink {
            route = "user.summary";
            text = I18n.t("user.summary.title");
            title = I18n.t("user.summary.title");
            name = "user-summary";
            prefixType = "icon";
            prefixValue = "user";

            constructor() {
              super(...arguments);
            }

            get model() {
              return userController.model || currentUser;
            }
          };

          const UserSummarySection = class extends BaseCustomSidebarSection {
            hideSectionHeader = true;
            name = "user-summary";
            displaySection = true;

            get sectionLinks() {
              return UserSummaryLink;
            }

            get text() {
              return null;
            }

            get links() {
              return [new UserSummaryLink()];
            }
          };
          return UserSummarySection;
        },
        SIDEBAR_USER_PANEL
      );

      // user invites
      api.addSidebarSection(
        (BaseCustomSidebarSection, BaseCustomSidebarSectionLink) => {
          const UserInviteLink = class extends BaseCustomSidebarSectionLink {
            route = "userInvited";
            text = I18n.t("user.invited.title");
            title = I18n.t("user.invited.title");
            name = "user-invites";
            prefixType = "icon";
            prefixValue = "user-plus";

            constructor() {
              super(...arguments);
            }

            get model() {
              return userController.model || currentUser;
            }
          };

          const UserInviteSection = class extends BaseCustomSidebarSection {
            hideSectionHeader = true;
            name = "user-invites";

            get displaySection() {
              return currentUser.can_invite_to_forum;
            }

            get sectionLinks() {
              return UserInviteLink;
            }

            get text() {
              return null;
            }

            get links() {
              return [new UserInviteLink()];
            }
          };

          return UserInviteSection;
        },
        SIDEBAR_USER_PANEL
      );

      // user badges
      api.addSidebarSection(
        (BaseCustomSidebarSection, BaseCustomSidebarSectionLink) => {
          const UserBadgesLink = class extends BaseCustomSidebarSectionLink {
            route = "user.badges";
            text = I18n.t("badges.title");
            title = I18n.t("badges.title");
            name = "user-badges";
            prefixType = "icon";
            prefixValue = "certificate";

            constructor() {
              super(...arguments);
            }

            get model() {
              return userController.model || currentUser;
            }
          };

          const UserBadgeSection = class extends BaseCustomSidebarSection {
            hideSectionHeader = true;
            name = "user-badges";

            get displaySection() {
              return siteSettings.enable_badges;
            }

            get sectionLinks() {
              return UserBadgesLink;
            }

            get text() {
              return null;
            }

            get links() {
              return [new UserBadgesLink()];
            }
          };

          return UserBadgeSection;
        },
        SIDEBAR_USER_PANEL
      );

      // user activity section
      api.addSidebarSection(
        (BaseCustomSidebarSection, BaseCustomSidebarSectionLink) => {
          const UserSummaryLink = class extends BaseCustomSidebarSectionLink {
            route = "userActivity.index";
            text = I18n.t("user.filters.all");
            title = I18n.t("user.filters.all");
            name = "user-activity";
            prefixType = "icon";
            prefixValue = "list";

            get model() {
              return userController.model || currentUser;
            }
          };

          const UserPostsLink = class extends BaseCustomSidebarSectionLink {
            route = "userActivity.topics";
            text = I18n.t("user_action_groups.4");
            title = I18n.t("user_action_groups.4");
            name = "user-topics";
            prefixType = "icon";
            prefixValue = "list-ul";

            get model() {
              return userController.model || currentUser;
            }
          };

          const UserRepliesLink = class extends BaseCustomSidebarSectionLink {
            route = "userActivity.replies";
            text = I18n.t("user_action_groups.5");
            title = I18n.t("user_action_groups.5");
            name = "user-replies";
            prefixType = "icon";
            prefixValue = "reply";

            get model() {
              return userController.model || currentUser;
            }
          };

          const UserReadLink = class extends BaseCustomSidebarSectionLink {
            route = "userActivity.read";
            text = I18n.t("user.read");
            title = I18n.t("user.read_help");
            name = "user-read";
            prefixType = "icon";
            prefixValue = "clock";

            get model() {
              return userController.model || currentUser;
            }
          };

          const UserDraftsLink = class extends BaseCustomSidebarSectionLink {
            route = "userActivity.drafts";
            text = I18n.t("drafts.label");
            title = I18n.t("drafts.label");
            name = "user-drafts";
            prefixType = "icon";
            prefixValue = "pencil";

            get model() {
              return userController.model || currentUser;
            }
          };

          const UserPendingLink = class extends BaseCustomSidebarSectionLink {
            route = "userActivity.pending";
            text = I18n.t("user.pending");
            title = I18n.t("user.pending");
            name = "user-pending";
            prefixType = "icon";
            prefixValue = "clock";

            get model() {
              return userController.model || currentUser;
            }
          };

          const UserLikesGivenLink = class extends BaseCustomSidebarSectionLink {
            route = "userActivity.likesGiven";
            text = I18n.t("user_action_groups.1");
            title = I18n.t("user_action_groups.1");
            name = "user-likes-given";
            prefixType = "icon";
            prefixValue = "heart";

            get model() {
              return userController.model || currentUser;
            }
          };

          const UserBookmarksLink = class extends BaseCustomSidebarSectionLink {
            route = "userActivity.bookmarks";
            text = I18n.t("user_action_groups.3");
            title = I18n.t("user_action_groups.3");
            name = "user-bookmarks";
            prefixType = "icon";
            prefixValue = "bookmark";

            get model() {
              return userController.model || currentUser;
            }
          };

          const UserActivitySection = class extends BaseCustomSidebarSection {
            hideSectionHeader = false;
            name = "user-activity";

            get displaySection() {
              const viewingUser = userController.model;

              return (
                viewingUser?.id === currentUser?.id ||
                currentUser?.admin ||
                !siteSettings.hide_user_activity_tab
              );
            }

            get sectionLinks() {
              const links = [
                new UserSummaryLink(),
                new UserPostsLink(),
                new UserRepliesLink(),
                new UserLikesGivenLink(),
              ];

              if (userController.showRead) {
                links.push(new UserReadLink());
              }

              if (userController.showDrafts) {
                links.push(new UserDraftsLink());
              }

              if (currentUser.pending_posts_count > 0) {
                links.push(new UserPendingLink());
              }

              if (userController.showBookmarks) {
                links.push(new UserBookmarksLink());
              }

              return links;
            }

            get text() {
              return I18n.t("user.activity_stream");
            }

            get links() {
              return this.sectionLinks;
            }
          };

          return UserActivitySection;
        },
        SIDEBAR_USER_PANEL
      );

      // user notifications
      api.addSidebarSection(
        (BaseCustomSidebarSection, BaseCustomSidebarSectionLink) => {
          const UserNotificationsLink = class extends BaseCustomSidebarSectionLink {
            route = "userNotifications.index";
            text = I18n.t("user.filters.all");
            title = I18n.t("user.filters.all");
            name = "user-notifications";
            prefixType = "icon";
            prefixValue = "bell";

            get model() {
              return userController.model || currentUser;
            }
          };

          const UserResponsesLink = class extends BaseCustomSidebarSectionLink {
            route = "userNotifications.responses";
            text = I18n.t("user_action_groups.6");
            title = I18n.t("user_action_groups.6");
            name = "user-responses";
            prefixType = "icon";
            prefixValue = "reply";

            get model() {
              return userController.model || currentUser;
            }
          };

          const UserLikesReceivedLink = class extends BaseCustomSidebarSectionLink {
            route = "userNotifications.likesReceived";
            text = I18n.t("user_action_groups.2");
            title = I18n.t("user_action_groups.2");
            name = "user-likes-received";
            prefixType = "icon";
            prefixValue = "heart";

            get model() {
              return userController.model || currentUser;
            }
          };

          const UserMentionsLink = class extends BaseCustomSidebarSectionLink {
            route = "userNotifications.mentions";
            text = I18n.t("user_action_groups.7");
            title = I18n.t("user_action_groups.7");
            name = "user-mentions";
            prefixType = "icon";
            prefixValue = "at";

            get model() {
              return userController.model || currentUser;
            }
          };

          const UserEditsLink = class extends BaseCustomSidebarSectionLink {
            route = "userNotifications.edits";
            text = I18n.t("user_action_groups.11");
            title = I18n.t("user_action_groups.11");
            name = "user-edits";
            prefixType = "icon";
            prefixValue = "pencil";

            get model() {
              return userController.model || currentUser;
            }
          };

          const UserLinksLink = class extends BaseCustomSidebarSectionLink {
            route = "userNotifications.links";
            text = I18n.t("user_action_groups.17");
            title = I18n.t("user_action_groups.17");
            name = "user-links";
            prefixType = "icon";
            prefixValue = "link";

            get model() {
              return userController.model || currentUser;
            }
          };

          const UserNotificationsSection = class extends BaseCustomSidebarSection {
            hideSectionHeader = false;
            name = "user-notifications";

            get displaySection() {
              const viewingUser = userController.model;

              return viewingUser?.id === currentUser?.id || currentUser?.admin;
            }

            get sectionLinks() {
              const links = [
                new UserNotificationsLink(),
                new UserResponsesLink(),
                new UserLikesReceivedLink(),
                new UserEditsLink(),
                new UserLinksLink(),
              ];

              if (siteSettings.enable_mentions) {
                links.push(new UserMentionsLink());
              }

              return links;
            }

            get text() {
              return I18n.t("user.notifications");
            }

            get links() {
              return this.sectionLinks;
            }
          };

          return UserNotificationsSection;
        },
        SIDEBAR_USER_PANEL
      );

      // user messages
      api.addSidebarSection(
        (BaseCustomSidebarSection, BaseCustomSidebarSectionLink) => {
          const LatestMessagesLink = class extends BaseCustomSidebarSectionLink {
            route = "userPrivateMessages.user.index";
            text = I18n.t("categories.latest");
            title = I18n.t("categories.latest");
            name = "latest-messages";
            prefixType = "icon";
            prefixValue = "envelope";

            get model() {
              return userController.model || currentUser;
            }
          };

          const SentMessagesLink = class extends BaseCustomSidebarSectionLink {
            route = "userPrivateMessages.user.sent";
            text = I18n.t("user.messages.sent");
            title = I18n.t("user.messages.sent");
            name = "sent-messages";
            prefixType = "icon";
            prefixValue = "reply";

            get model() {
              return userController.model || currentUser;
            }
          };

          const NewMessagesLink = class extends BaseCustomSidebarSectionLink {
            route = "userPrivateMessages.user.new";
            text = I18n.t("user.messages.new");
            title = I18n.t("user.messages.new");
            name = "new-messages";
            prefixType = "icon";
            prefixValue = "circle";

            get model() {
              return userController.model || currentUser;
            }
          };

          const UnreadMessagesLink = class extends BaseCustomSidebarSectionLink {
            route = "userPrivateMessages.user.unread";
            text = I18n.t("user.messages.unread");
            title = I18n.t("user.messages.unread");
            name = "unread-messages";
            prefixType = "icon";
            prefixValue = "plus";

            get model() {
              return userController.model || currentUser;
            }
          };

          const ArchiveMessagesLink = class extends BaseCustomSidebarSectionLink {
            route = "userPrivateMessages.user.archive";
            text = I18n.t("user.messages.archive");
            title = I18n.t("user.messages.archive");
            name = "archive-messages";
            prefixType = "icon";
            prefixValue = "folder";

            get model() {
              return userController.model || currentUser;
            }
          };

          const UserMessagesSection = class extends BaseCustomSidebarSection {
            hideSectionHeader = false;
            name = "user-messages";

            get displaySection() {
              const viewingUser = userController.model;

              return (
                currentUser?.can_send_private_messages &&
                (viewingUser?.id === currentUser?.id || currentUser?.admin)
              );
            }

            get sectionLinks() {
              const links = [
                new LatestMessagesLink(),
                new SentMessagesLink(),
                new ArchiveMessagesLink(),
              ];

              const viewingUser = userController.model;

              if (viewingUser?.id === currentUser?.id) {
                links.push(new NewMessagesLink());
                links.push(new UnreadMessagesLink());
              }

              return links;
            }

            get text() {
              return I18n.t("user.private_messages");
            }

            get links() {
              return this.sectionLinks;
            }
          };

          return UserMessagesSection;
        },
        SIDEBAR_USER_PANEL
      );

      // user preferences
      api.addSidebarSection(
        (BaseCustomSidebarSection, BaseCustomSidebarSectionLink) => {
          const AccountPreferencesLink = class extends BaseCustomSidebarSectionLink {
            route = "preferences.account";
            text = I18n.t("user.preferences_nav.account");
            title = I18n.t("user.preferences_nav.account");
            name = "preferences-account";
            prefixType = "icon";
            prefixValue = "user";

            get model() {
              return userController.model || currentUser;
            }
          };

          const SecurityPreferencesLink = class extends BaseCustomSidebarSectionLink {
            route = "preferences.security";
            text = I18n.t("user.preferences_nav.security");
            title = I18n.t("user.preferences_nav.security");
            name = "preferences-security";
            prefixType = "icon";
            prefixValue = "lock";

            get model() {
              return userController.model || currentUser;
            }
          };

          const ProfilePreferencesLink = class extends BaseCustomSidebarSectionLink {
            route = "preferences.profile";
            text = I18n.t("user.preferences_nav.profile");
            title = I18n.t("user.preferences_nav.profile");
            name = "preferences-profile";
            prefixType = "icon";
            prefixValue = "user";

            get model() {
              return userController.model || currentUser;
            }
          };

          const EmailsPreferencesLink = class extends BaseCustomSidebarSectionLink {
            route = "preferences.emails";
            text = I18n.t("user.preferences_nav.emails");
            title = I18n.t("user.preferences_nav.emails");
            name = "preferences-emails";
            prefixType = "icon";
            prefixValue = "envelope";

            get model() {
              return userController.model || currentUser;
            }
          };

          const NotificationsPreferencesLink = class extends BaseCustomSidebarSectionLink {
            route = "preferences.notifications";
            text = I18n.t("user.preferences_nav.notifications");
            title = I18n.t("user.preferences_nav.notifications");
            name = "preferences-notifications";
            prefixType = "icon";
            prefixValue = "bell";

            get model() {
              return userController.model || currentUser;
            }
          };

          const TrackingPreferencesLink = class extends BaseCustomSidebarSectionLink {
            route = "preferences.tracking";
            text = I18n.t("user.preferences_nav.tracking");
            title = I18n.t("user.preferences_nav.tracking");
            name = "preferences-tracking";
            prefixType = "icon";
            prefixValue = "plus";

            get model() {
              return userController.model || currentUser;
            }
          };

          const UsersPreferencesLink = class extends BaseCustomSidebarSectionLink {
            route = "preferences.users";
            text = I18n.t("user.preferences_nav.users");
            title = I18n.t("user.preferences_nav.users");
            name = "preferences-users";
            prefixType = "icon";
            prefixValue = "users";

            get model() {
              return userController.model || currentUser;
            }
          };

          const InterfacePreferencesLink = class extends BaseCustomSidebarSectionLink {
            route = "preferences.interface";
            text = I18n.t("user.preferences_nav.interface");
            title = I18n.t("user.preferences_nav.interface");
            name = "preferences-interface";
            prefixType = "icon";
            prefixValue = "desktop";

            get model() {
              return userController.model || currentUser;
            }
          };

          const NavigationMenuPreferencesLink = class extends BaseCustomSidebarSectionLink {
            route = "preferences.navigation-menu";
            text = I18n.t("user.preferences_nav.navigation_menu");
            title = I18n.t("user.preferences_nav.navigation_menu");
            name = "preferences-navigation-menu";
            prefixType = "icon";
            prefixValue = "bars";

            get model() {
              return userController.model || currentUser;
            }
          };

          const UserPreferencesSection = class extends BaseCustomSidebarSection {
            hideSectionHeader = false;
            name = "user-preferences";

            get displaySection() {
              return router.currentRoute?.parent?.attributes?.can_edit;
            }

            get sectionLinks() {
              const links = [
                new AccountPreferencesLink(),
                new SecurityPreferencesLink(),
                new ProfilePreferencesLink(),
                new EmailsPreferencesLink(),
                new NotificationsPreferencesLink(),
                new UsersPreferencesLink(),
                new InterfacePreferencesLink(),
                new NavigationMenuPreferencesLink(),
              ];

              if (userController.can_change_tracking_preferences) {
                links.push(new TrackingPreferencesLink());
              }

              return links;
            }

            get text() {
              return I18n.t("user.preferences.title");
            }

            get links() {
              return this.sectionLinks;
            }
          };

          return UserPreferencesSection;
        },
        SIDEBAR_USER_PANEL
      );
    });
  },
};
