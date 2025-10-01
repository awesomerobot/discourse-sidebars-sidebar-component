import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import { SIDEBAR_ABOUT_PANEL } from "../services/about-sidebar";

export default class AboutSidebarHeader extends Component {
  @service router;
  @service composer;
  @service sidebarState;

  get shouldShow() {
    return this.sidebarState?.currentPanel && this.sidebarState.isCurrentPanel(SIDEBAR_ABOUT_PANEL);
  }

  @action
  contactModerators() {
    this.composer.openNewMessage({
      recipients: "moderators",
    });
  }

  <template>
    {{#if this.shouldShow}}
      <div class="about-sidebar-header">
        <div class="about-sidebar-header__actions">
          <DButton
            @action={{this.contactModerators}}
            @label="about.contact"
            @icon="envelope"
            @title="Contact moderators"
            class="btn-default compose-pm"
          />
        </div>
      </div>
    {{/if}}
  </template>
}
