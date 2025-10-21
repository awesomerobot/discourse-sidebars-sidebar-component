import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DMenu from "discourse/components/d-menu";
import ChatModalNewMessage from "discourse/plugins/chat/discourse/components/chat/modal/new-message";
import CreateChannelModal from "discourse/plugins/chat/discourse/components/chat/modal/create-channel";
import icon from "discourse-common/helpers/d-icon";
import i18n from "discourse-common/helpers/i18n";

export default class ChatSidebarHeader extends Component {
  @service router;
  @service currentUser;
  @service siteSettings;
  @service chat;
  @service modal;

  get shouldShow() {
    return (
      this.siteSettings.chat_enabled &&
      this.router.currentRouteName?.includes("chat")
    );
  }

  get canCreateDirectMessage() {
    return this.currentUser?.can_send_private_messages;
  }

  get canCreateChannel() {
    // Check if user can create channels (typically admin or moderator)
    return (
      this.currentUser?.admin ||
      this.currentUser?.moderator ||
      this.siteSettings.chat_allow_moderators_to_create_channels
    );
  }

  get hasAnyCreatePermission() {
    return this.canCreateDirectMessage || this.canCreateChannel;
  }

  get hasMultipleOptions() {
    return this.canCreateDirectMessage && this.canCreateChannel;
  }

  @action
  onRegisterApi(api) {
    this.dMenu = api;
  }

  @action
  createDirectMessage() {
    this.dMenu?.close();
    this.modal.show(ChatModalNewMessage);
  }

  @action
  createChannel() {
    this.dMenu?.close();
    this.modal.show(CreateChannelModal);
  }

  <template>
    {{#if this.shouldShow}}
      <div class="chat-sidebar-header">
        <div class="chat-sidebar-header__actions">
          {{#if this.hasMultipleOptions}}
            {{! Show dropdown menu when user has multiple options }}
            <DMenu
              @label={{i18n (themePrefix "chat_header.new_chat")}}
              @icon="plus"
              @onRegisterApi={{this.onRegisterApi}}
              class="btn-default new-chat-btn"
              @modalForMobile={{true}}
            >
              <:content>
                <ul class="chat-new-menu">
                  <li>
                    <DButton
                      @action={{this.createDirectMessage}}
                      @icon="user"
                      @translatedLabel={{i18n
                        (themePrefix "chat_header.new_direct_message")
                      }}
                      class="btn-transparent chat-new-menu__item"
                    />
                  </li>
                  <li>
                    <DButton
                      @action={{this.createChannel}}
                      @icon="comment"
                      @translatedLabel={{i18n
                        (themePrefix "chat_header.new_channel")
                      }}
                      class="btn-transparent chat-new-menu__item"
                    />
                  </li>
                </ul>
              </:content>
            </DMenu>
          {{else if this.canCreateDirectMessage}}
            {{! Show direct button for DM only }}
            <DButton
              @action={{this.createDirectMessage}}
              @icon="plus"
              @translatedLabel={{i18n
                (themePrefix "chat_header.new_direct_message")
              }}
              class="btn-default new-chat-btn"
            />
          {{else if this.canCreateChannel}}
            {{! Show direct button for Channel only }}
            <DButton
              @action={{this.createChannel}}
              @icon="plus"
              @translatedLabel={{i18n (themePrefix "chat_header.new_channel")}}
              class="btn-default new-chat-btn"
            />
          {{/if}}
        </div>
      </div>
    {{/if}}
  </template>
}
