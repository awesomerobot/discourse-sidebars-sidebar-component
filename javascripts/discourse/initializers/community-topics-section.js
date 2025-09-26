import { withPluginApi } from "discourse/lib/plugin-api";
import I18n from "I18n";

export default {
  name: "community-topics-section",
  initialize(container) {
    withPluginApi("1.34.0", (api) => {
      const siteSettings = container.lookup("service:site-settings");

      // Parse top_menu setting and create links
      if (siteSettings.top_menu) {
        const topMenuItems = siteSettings.top_menu.split("|");

        topMenuItems.forEach((item) => {
          const trimmedItem = item.trim();
          if (!trimmedItem) return;

          // Map common top menu items to routes and display names
          let route, displayName, icon;

          switch (trimmedItem) {
            case "latest":
              route = "discovery.latest";
              displayName = I18n.t("filters.latest.title");
              icon = "far-clock";
              break;
            case "new":
              route = "discovery.new";
              displayName = I18n.t("filters.new.title");
              icon = "seedling";
              break;
            case "unread":
              route = "discovery.unread";
              displayName = I18n.t("filters.unread.title");
              icon = "circle";
              break;
            case "top":
              route = "discovery.top";
              displayName = I18n.t("filters.top.title");
              icon = "trophy";
              break;
            case "hot":
              route = "discovery.hot";
              displayName = I18n.t("filters.hot.title");
              icon = "fire";
              break;
            case "categories":
              route = "discovery.categories";
              displayName = I18n.t("filters.categories.title");
              icon = "list";
              break;
            default:
              // For custom items, use the item name as both route and display
              route = `discovery.${trimmedItem}`;
              displayName =
                trimmedItem.charAt(0).toUpperCase() + trimmedItem.slice(1);
              icon = "list";
          }

          api.addCommunitySectionLink((BaseCommunitySectionLink) => {
            return class extends BaseCommunitySectionLink {
              get name() {
                return `topic-${trimmedItem}`;
              }

              get route() {
                return route;
              }

              get text() {
                return displayName;
              }

              get title() {
                return displayName;
              }

              get defaultPrefixValue() {
                return icon;
              }
            };
          });
        });
      }
    });
  },
};
