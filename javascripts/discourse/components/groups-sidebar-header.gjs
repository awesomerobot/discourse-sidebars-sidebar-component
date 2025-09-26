import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DiscourseURL from "discourse/lib/url";
import dIcon from "discourse-common/helpers/d-icon";
import i18n from "discourse-common/helpers/i18n";

export default class GroupsSidebarHeader extends Component {
  @service router;
  @service currentUser;

  get shouldShow() {
    return (
      this.router.currentRouteName?.includes("groups") ||
      this.router.currentURL?.includes("/g/")
    );
  }

  @action
  createNewGroup() {
    DiscourseURL.routeTo("/g/custom/new");
  }

  <template>
    {{#if this.shouldShow}}
      <div class="groups-sidebar-header">
        <div class="groups-sidebar-header__actions">
          {{#if this.currentUser.can_create_group}}
            <DButton
              @action={{this.createNewGroup}}
              @icon="plus"
              @label="admin.groups.new.title"
              class="btn-default create-group-btn"
            />
          {{/if}}
        </div>
      </div>
    {{/if}}
  </template>
}
