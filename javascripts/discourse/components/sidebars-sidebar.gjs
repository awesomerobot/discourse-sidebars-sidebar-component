import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { action } from "@ember/object";
import { getOwner } from "@ember/owner";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import { service } from "@ember/service";
import { eq } from "truth-helpers";
import DButton from "discourse/components/d-button";
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
  @service docsSidebar;

  @tracked activeState = null;
  @tracked docsModeCategory = settings.docs_mode_category;

  docsModeCategoryID = parseInt(this.docsModeCategory, 10);
  currentURL = this.router.currentURL;

  get chatEnabled() {
    return this.siteSettings.chat_enabled;
  }

  get shouldShow() {
    return this.currentUser && this.chatEnabled;
  }

  @action
  async setActive() {
    this.docsModeCategory = await Category.asyncFindById(
      this.docsModeCategoryID
    );

    this.currentURL = this.router.currentURL;

    const currentRoute = this.router.currentRouteName;
    const topicController = getOwner(this).lookup("controller:topic");
    const topic = topicController?.model;
    const topicCategory = topic
      ? await Category.asyncFindById(topic?.category_id)
      : null;

    this.sidebarState.mode = SEPARATED_MODE;

    if (currentRoute.includes("admin")) {
      this.activeState = "admin";
    } else if (currentRoute.includes("chat")) {
      this.activeState = "chat";
      this.sidebarState.setPanel("chat");
    } else if (
      this.currentURL.includes(this.docsModeCategory.url) ||
      this.currentURL.includes(`/c/${this.docsModeCategoryID}`) ||
      topic?.category_id === this.docsModeCategoryID ||
      topicCategory?.parentCategory?.id === this.docsModeCategoryID
    ) {
      this.activeState = "docs";
    } else if (
      currentRoute.includes("user") ||
      currentRoute.includes("preferences")
    ) {
      this.activeState = "user";
    } else {
      this.activeState = "forum";
      this.sidebarState.setPanel("main");
    }
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
          @icon="layer-group"
          @action={{fn this.switchState "forum"}}
          @class="btn-flat {{if (eq this.activeState 'forum') 'active'}}"
          @translatedLabel={{i18n (themePrefix "sidebar_buttons.topics")}}
        />
        <DButton
          @icon="d-chat"
          @action={{fn this.switchState "chat"}}
          @class="btn-flat {{if (eq this.activeState 'chat') 'active'}}"
          @translatedLabel={{i18n (themePrefix "sidebar_buttons.chat")}}
        />
        <DButton
          @icon="user"
          @action={{fn this.switchState "user"}}
          @class="btn-flat {{if (eq this.activeState 'user') 'active'}}"
          @translatedLabel={{i18n (themePrefix "sidebar_buttons.user")}}
        />
        {{#if this.docsModeCategory}}
          <DButton
            @icon="file-alt"
            @action={{fn this.switchState "docs"}}
            @class="btn-flat {{if (eq this.activeState 'docs') 'active'}}"
            @translatedLabel={{i18n (themePrefix "sidebar_buttons.docs")}}
          />
        {{/if}}
        {{#if this.currentUser.admin}}
          <DButton
            @icon="wrench"
            @action={{fn this.switchState "admin"}}
            @class="btn-flat {{if (eq this.activeState 'admin') 'active'}}"
            @translatedLabel={{i18n (themePrefix "sidebar_buttons.admin")}}
          />
        {{/if}}
      </div>
    {{/if}}
  </template>
}
