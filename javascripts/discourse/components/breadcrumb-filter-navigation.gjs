import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { getOwner } from "@ember/owner";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import { service } from "@ember/service";
import BulkSelectToggle from "discourse/components/bulk-select-toggle";
import FilterNavigationMenu from "discourse/components/discovery/filter-navigation-menu";
import DiscourseURL from "discourse/lib/url";
import { bind } from "discourse/lib/decorators";
import { applyValueTransformer } from "discourse/lib/transformer";
import FilterSuggestions from "discourse/lib/filter-suggestions";
import { ajax } from "discourse/lib/ajax";

export default class BreadcrumbFilterNavigation extends Component {
  @service router;
  @service site;

  @tracked category;
  @tracked tag;
  @tracked filterQueryString = "";
  @tracked filterOptions = null;

  get discoveryController() {
    return getOwner(this).lookup("controller:discovery");
  }

  async fetchFilterOptions() {
    if (this.filterOptions) {
      return this.filterOptions;
    }

    try {
      const response = await ajax("/filter.json");
      this.filterOptions = response.topic_list?.filter_option_info || [];
      return this.filterOptions;
    } catch (error) {
      console.error("Failed to fetch filter options:", error);
      return [];
    }
  }

  get tips() {
    // If we have fetched filter options from backend, use those
    if (this.filterOptions && Array.isArray(this.filterOptions)) {
      return this.filterOptions;
    }

    // Otherwise, fetch them (this will trigger a re-render when done)
    this.fetchFilterOptions().then((options) => {
      if (options && options.length > 0) {
        // Force a re-render when options are loaded
        this.filterOptions = options;
      }
    });

    // Fallback to basic tips while loading
    const tips = [
      {
        name: "category:",
        description: "Filter by category",
        type: "category",
        priority: 1,
      },
      // Only add tag filter if tagging is enabled
      ...(this.site.can_tag_topics
        ? [
            {
              name: "tag:",
              description: "Filter by tag",
              type: "tag",
              priority: 1,
            },
          ]
        : []),
      {
        name: "status:",
        description: "Filter by topic status",
        type: "text",
        priority: 1,
      },
      {
        name: "created:",
        description: "Filter by creation date",
        type: "date",
        priority: 1,
      },
      {
        name: "posts:",
        description: "Filter by post count",
        type: "number",
        priority: 1,
      },
      {
        name: "likes:",
        description: "Filter by like count",
        type: "number",
        priority: 1,
      },
      {
        name: "user:",
        description: "Filter by username",
        type: "username",
        priority: 1,
      },
      {
        name: "before:",
        description: "Before date",
        type: "date",
        priority: 2,
      },
      {
        name: "after:",
        description: "After date",
        type: "date",
        priority: 2,
      },
      {
        name: "in:",
        description: "Search scope",
        type: "text",
        priority: 2,
      },
    ];

    // Add order filters - base filter plus all specific options
    tips.push({
      name: "order:",
      description: "Sort order",
      priority: 1,
    });

    // Add specific order options
    const orderOptions = [
      { name: "order:activity", description: "Sort by activity" },
      {
        name: "order:activity-asc",
        description: "Sort by activity (ascending)",
      },
      { name: "order:category", description: "Sort by category" },
      {
        name: "order:category-asc",
        description: "Sort by category (ascending)",
      },
      { name: "order:created", description: "Sort by creation date" },
      {
        name: "order:created-asc",
        description: "Sort by creation date (ascending)",
      },
      { name: "order:latest-post", description: "Sort by latest post" },
      {
        name: "order:latest-post-asc",
        description: "Sort by latest post (ascending)",
      },
      { name: "order:likes", description: "Sort by likes" },
      { name: "order:likes-asc", description: "Sort by likes (ascending)" },
      { name: "order:likes-op", description: "Sort by OP likes" },
      {
        name: "order:likes-op-asc",
        description: "Sort by OP likes (ascending)",
      },
      { name: "order:posters", description: "Sort by posters" },
      { name: "order:posters-asc", description: "Sort by posters (ascending)" },
      { name: "order:title", description: "Sort by title" },
      { name: "order:title-asc", description: "Sort by title (ascending)" },
      { name: "order:views", description: "Sort by views" },
      { name: "order:views-asc", description: "Sort by views (ascending)" },
      { name: "order:hot", description: "Sort by hot score" },
      { name: "order:hot-asc", description: "Sort by hot score (ascending)" },
      { name: "order:read", description: "Sort by read status" },
      {
        name: "order:read-asc",
        description: "Sort by read status (ascending)",
      },
    ];

    tips.push(...orderOptions);

    return tips;
  }

  get shouldShow() {
    const currentRoute = this.router.currentRouteName;
    return (
      (currentRoute?.startsWith("discovery.") ||
        currentRoute?.startsWith("tag.")) &&
      !currentRoute?.includes("categories")
    );
  }

  get showBulkSelectInNavControls() {
    const enableOnDesktop = applyValueTransformer(
      "bulk-select-in-nav-controls",
      false,
      { site: this.site }
    );

    return this.site.mobileView || enableOnDesktop;
  }

  @action
  getCategoryAndTag() {
    this.category = this.router.currentRoute?.attributes?.category || null;
    this.tag = this.router.currentRoute?.attributes?.tag || null;

    // Build initial query string based on context
    let queryParts = [];

    if (this.category) {
      queryParts.push(`category:${this.category.slug}`);
    }

    if (this.tag) {
      queryParts.push(`tag:${this.tag.id}`);
    }

    // Only add order filter for generic routes (not category/tag specific routes)
    if (!this.category && !this.tag) {
      // Detect current sort order from route
      const currentRouteName = this.router.currentRouteName;
      let sortOrder = "latest"; // default

      if (currentRouteName?.includes(".new")) {
        sortOrder = "created";
      } else if (currentRouteName?.includes(".unread")) {
        sortOrder = "activity";
      } else if (currentRouteName?.includes(".top")) {
        sortOrder = "likes";
      } else if (currentRouteName?.includes(".hot")) {
        sortOrder = "hot";
      }

      queryParts.push(`order:${sortOrder}`);
    }

    this.filterQueryString = queryParts.join(" ");
  }

  get originalContextUrl() {
    let url = "/";

    if (this.category && this.tag) {
      url = `/tags/c/${this.category.slug}/${this.category.id}/${this.tag.id}`;
    } else if (this.category) {
      url = `/c/${this.category.slug}/${this.category.id}`;
    } else if (this.tag) {
      url = `/tag/${this.tag.id}`;
    }

    return url;
  }

  @bind
  updateQueryString(newQueryString, refresh) {
    this.filterQueryString = newQueryString;

    if (refresh) {
      if (newQueryString.trim() === "") {
        // If clearing the filter, go to empty filter page
        DiscourseURL.routeTo("/filter");
      } else {
        // Navigate to filter route with the new query
        DiscourseURL.routeTo(`/filter?q=${encodeURIComponent(newQueryString)}`);
      }
    }
  }

  <template>
    {{#if this.shouldShow}}
      <section
        class="breadcrumb-filter-navigation"
        {{didInsert this.getCategoryAndTag}}
        {{didUpdate this.getCategoryAndTag this.router.currentRoute}}
      >
        <div class="topic-query-filter">
          {{#if this.showBulkSelectInNavControls}}
            <div class="topic-query-filter__bulk-action-btn">
              <BulkSelectToggle @bulkSelectHelper={{@args.bulkSelectHelper}} />
            </div>
          {{/if}}

          <FilterNavigationMenu
            @onChange={{this.updateQueryString}}
            @initialInputValue={{this.filterQueryString}}
            @tips={{this.tips}}
          />
        </div>
      </section>
    {{/if}}
  </template>
}
