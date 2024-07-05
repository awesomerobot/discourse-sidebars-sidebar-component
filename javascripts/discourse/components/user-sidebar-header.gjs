import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { action } from "@ember/object";
import { getOwner } from "@ember/owner";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import avatar from "discourse/helpers/bound-avatar-template";
import routeAction from "discourse/helpers/route-action";
import { popupAjaxError } from "discourse/lib/ajax-error";
import dIcon from "discourse-common/helpers/d-icon";
import i18n from "discourse-common/helpers/i18n";

export default class UserSidebarHeader extends Component {
  @service router;
  @service chat;
  @service currentUser;

  get shouldShow() {
    return (
      this.router.currentRouteName.includes("user") ||
      this.router.currentRouteName.includes("preferences")
    );
  }

  get user() {
    return getOwner(this).lookup("controller:user").model;
  }

  @action
  async startChatting() {
    try {
      const channel = await this.chat.upsertDmChannel({
        usernames: [this.user.username],
      });

      if (channel) {
        this.router.transitionTo("chat.channel", ...channel.routeModels);
      }
    } catch (error) {
      popupAjaxError(error);
    } finally {
      if (this.args.modal) {
        this.appEvents.trigger("card:close");
      }
    }
  }

  <template>
    {{#if this.shouldShow}}
      <div class="user-sidebar-header">
        <div class="user-sidebar-header__user">
          {{avatar this.user.avatar_template "medium"}}
          <span class="user-sidebar-header__user-name">
            <span class="user-name-first">{{this.user.username}}</span>
            <span class="user-name-second">{{this.user.name}}</span>
          </span>
        </div>
        <div class="user-sidebar-header__actions">
          <DButton
            @action={{fn (routeAction "composePrivateMessage") this.user}}
            @icon="envelope"
            @title="user.private_message"
            class="btn-default compose-pm"
          />
          <DButton
            @action={{this.startChatting}}
            @title="chat.title_capitalized"
            @icon="d-chat"
            class="btn-default chat-direct-message-btn"
          />
          {{#if this.currentUser.admin}}
            <a
              href={{this.user.adminPath}}
              title={{i18n "admin.user.show_admin_profile"}}
              class="btn btn-default no-text icon-only user-admin"
            >
              {{dIcon "wrench"}}
            </a>
          {{/if}}
        </div>
      </div>
    {{/if}}
  </template>
}
