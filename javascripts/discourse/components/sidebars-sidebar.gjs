import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { getOwner } from "@ember/owner";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import { service } from "@ember/service";
import { eq } from "truth-helpers";
import DButton from "discourse/components/d-button";
import avatar from "discourse/helpers/bound-avatar-template";
import bodyClass from "discourse/helpers/body-class";
import { SEPARATED_MODE } from "discourse/lib/sidebar/panels";
import DiscourseURL, { userPath } from "discourse/lib/url";
import Category from "discourse/models/category";
import i18n from "discourse-common/helpers/i18n";

export default class SidebarsSidebar extends Component {
  @service router;
  @service chatStateManager;
  @service currentUser;
  @service siteSettings;
  @service sidebarState;
  @service docCategorySidebar;
  @service groupsSidebar;
  @service aboutSidebar;
  @service store;

  @tracked activeState = null;
  @tracked docsModeCategory = settings.docs_mode_category || null;
  @tracked reviewableCount = 0;

  docsModeCategoryID = parseInt(this.docsModeCategory, 10);
  currentURL = this.router.currentURL;

  get chatEnabled() {
    return this.siteSettings.chat_enabled;
  }

  get aiEnabled() {
    return this.siteSettings.ai_bot_enabled;
  }

  get showReviewLink() {
    return this.currentUser?.staff;
  }

  get shouldShow() {
    return this.currentUser;
  }

  @action
  async loadReviewableCount() {
    if (this.showReviewLink) {
      try {
        const result = await this.store.findAll("reviewable");
        this.reviewableCount = result?.content?.length || 0;
      } catch (error) {
        console.warn("Failed to load reviewable count:", error);
        this.reviewableCount = 0;
      }
    }
  }

  @action
  async setActive() {
    this.currentURL = this.router.currentURL;
    const currentRoute = this.router.currentRouteName;
    const topicController = getOwner(this).lookup("controller:topic");
    const topic = topicController?.model;

    if (!this.sidebarState) {
      return;
    }

    this.sidebarState.mode = SEPARATED_MODE;

    // Handle routes that don't need category lookups first
    if (currentRoute.includes("admin")) {
      this.activeState = "admin";
      return;
    }

    if (currentRoute.includes("chat")) {
      this.activeState = "chat";
      if (this.sidebarState) {
        this.sidebarState.setPanel("chat");
      }
      return;
    }

    if (currentRoute.includes("user") || currentRoute.includes("preferences")) {
      // Don't set user active state for users directory
      const isUsersDirectory =
        this.currentURL === "/u" || this.currentURL?.startsWith("/u?");

      if (!isUsersDirectory) {
        // Only set active if viewing current user's profile
        const userController = getOwner(this).lookup("controller:user");
        const viewingUser = userController?.model;

        if (
          viewingUser?.id === this.currentUser?.id ||
          currentRoute.includes("preferences")
        ) {
          this.activeState = "user";
        }
      }
      return;
    }

    if (currentRoute.includes("discourse-ai") || topic?.is_bot_pm) {
      this.activeState = "ai";
      if (this.sidebarState) {
        this.sidebarState.setPanel("ai-conversations");
      }
      return;
    }

    if (currentRoute.includes("groups") || this.currentURL.includes("/g/")) {
      this.activeState = "groups";
      if (this.sidebarState) {
        this.sidebarState.setPanel("discourse-sidebar-groups");
      }
      return;
    }

    if (this.currentURL.includes("/review")) {
      this.activeState = "review";
      return;
    }

    const isUsersDirectory =
      this.currentURL === "/u" || this.currentURL?.startsWith("/u?");

    if (
      this.currentURL.includes("/about") ||
      this.currentURL.includes("/faq") ||
      this.currentURL.includes("/privacy") ||
      this.currentURL.includes("/ap/about") ||
      (this.currentURL.includes("/badges") && !this.currentURL.includes("/u/")) ||
      this.currentURL.includes("/cakeday/anniversaries") ||
      this.currentURL.includes("/cakeday/birthdays") ||
      this.currentURL.includes("/leaderboard") ||
      isUsersDirectory
    ) {
      this.activeState = "about";
      if (this.sidebarState) {
        this.sidebarState.setPanel("discourse-sidebar-about");
      }
      return;
    }

    // Handle docs mode detection with async category lookups
    try {
      const categoryPromises = [];

      if (this.docsModeCategoryID) {
        categoryPromises.push(Category.asyncFindById(this.docsModeCategoryID));
      }

      if (topic?.category_id) {
        categoryPromises.push(Category.asyncFindById(topic.category_id));
      }

      const [docsModeCategory, topicCategory] = await Promise.all(
        categoryPromises
      );

      if (docsModeCategory) {
        this.docsModeCategory = docsModeCategory;
      }

      const isDocsMode =
        (docsModeCategory && this.currentURL.includes(docsModeCategory.url)) ||
        this.currentURL.includes(`/c/${this.docsModeCategoryID}`) ||
        (docsModeCategory &&
          this.currentURL.includes(`/c/${docsModeCategory.slug}`)) ||
        topic?.category_id === this.docsModeCategoryID ||
        topicCategory?.parentCategory?.id === this.docsModeCategoryID;

      if (isDocsMode) {
        this.activeState = "docs";
        if (this.sidebarState && this.docCategorySidebar) {
          this.docCategorySidebar.showDocsSidebar();
        }
        return;
      }
    } catch (error) {
      console.warn("Failed to load categories for docs mode detection:", error);
    }

    // Default to forum
    this.activeState = "forum";
    if (this.sidebarState) {
      this.sidebarState.setPanel("main");
    }

    // Load reviewable count
    this.loadReviewableCount();
  }

  @action
  switchState(mode) {
    switch (mode) {
      case "forum":
        DiscourseURL.routeTo("/");
        break;
      case "admin":
        DiscourseURL.routeTo("admin");
        break;
      case "chat":
        if (this.currentURL === "/chat/browse/open") {
          break;
        } else if (this.currentURL.includes("chat")) {
          DiscourseURL.routeTo("/chat/browse/open");
          break;
        } else {
          DiscourseURL.routeTo(this.chatStateManager.lastKnownChatURL);
        }
        break;
      case "docs":
        // using the ID avoids looking up the category with asyncFindById
        DiscourseURL.routeTo(`/c/${this.docsModeCategoryID}`);
        break;
      case "user":
        DiscourseURL.routeTo(
          `${userPath(this.currentUser.username.toLowerCase())}/summary`
        );
        break;
      case "ai":
        DiscourseURL.routeTo("/discourse-ai/ai-bot/conversations");
        break;
      case "groups":
        DiscourseURL.routeTo("/g");
        break;
      case "about":
        DiscourseURL.routeTo("/about");
        break;
      case "review":
        DiscourseURL.routeTo("/review");
        break;
      default:
        DiscourseURL.routeTo(this.chatStateManager.lastKnownAppURL);
    }
  }

  <template>
    {{#if this.shouldShow}}
      {{bodyClass "experimental-sidebars-sidebar"}}
      <div
        class="sidebars-sidebar__buttons"
        {{didInsert this.setActive}}
        {{didUpdate this.setActive this.router.currentRoute}}
      >
        <DButton
          @icon="landmark"
          @action={{fn this.switchState "forum"}}
          @class="btn-flat {{if (eq this.activeState 'forum') 'active'}}"
          @translatedLabel={{i18n (themePrefix "sidebar_buttons.topics")}}
        />
        {{#if this.chatEnabled}}
          <DButton
            @icon="d-chat"
            @action={{fn this.switchState "chat"}}
            @class="btn-flat {{if (eq this.activeState 'chat') 'active'}}"
            @translatedLabel={{i18n (themePrefix "sidebar_buttons.chat")}}
          />
        {{/if}}

        {{#if this.aiEnabled}}
          <DButton
            @icon="robot"
            @action={{fn this.switchState "ai"}}
            @class="btn-flat {{if (eq this.activeState 'ai') 'active'}}"
            @translatedLabel={{i18n (themePrefix "sidebar_buttons.ai")}}
          />
        {{/if}}
        <DButton
          @icon="users"
          @action={{fn this.switchState "groups"}}
          @class="btn-flat {{if (eq this.activeState 'groups') 'active'}}"
          @translatedLabel={{i18n (themePrefix "sidebar_buttons.groups")}}
        />

        {{#if this.docsModeCategory}}
          <DButton
            @icon="book"
            @action={{fn this.switchState "docs"}}
            @class="btn-flat {{if (eq this.activeState 'docs') 'active'}}"
            @translatedLabel={{i18n (themePrefix "sidebar_buttons.docs")}}
          />
        {{/if}}

        <DButton
          @icon="circle-info"
          @action={{fn this.switchState "about"}}
          @class="btn-flat sidebar-about-button {{if
            (eq this.activeState 'about')
            'active'
          }}"
          @translatedLabel={{i18n (themePrefix "sidebar_buttons.about")}}
        />

        {{#if this.showReviewLink}}
          <DButton
            @icon="flag"
            @action={{fn this.switchState "review"}}
            @class="btn-flat {{if (eq this.activeState 'review') 'active'}}"
            @translatedLabel={{i18n (themePrefix "sidebar_buttons.review")}}
          >
            {{#if this.reviewableCount}}
              <span class="badge-notification">{{this.reviewableCount}}</span>
            {{/if}}
          </DButton>
        {{/if}}

        {{#if this.currentUser.admin}}
          <DButton
            @icon="wrench"
            @action={{fn this.switchState "admin"}}
            @class="btn-flat {{if (eq this.activeState 'admin') 'active'}}"
            @translatedLabel={{i18n (themePrefix "sidebar_buttons.admin")}}
          />
        {{/if}}

        {{#if this.currentUser}}
          <button
            type="button"
            class="btn btn-flat sidebar-user-button
              {{if (eq this.activeState 'user') 'active'}}"
            {{on "click" (fn this.switchState "user")}}
            title={{i18n (themePrefix "sidebar_buttons.user")}}
          >
            {{avatar this.currentUser.avatar_template "tiny"}}
            <span class="d-button-label">{{i18n
                (themePrefix "sidebar_buttons.user")
              }}</span>
          </button>
        {{/if}}

      </div>
    {{/if}}
  </template>
}
