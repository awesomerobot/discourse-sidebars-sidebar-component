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
import SidebarsSidebar from "../components/sidebars-sidebar";

export default class AltMobileNav extends Component {
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

  <template>
    {{#if settings.mobile_footer_nav}}
      {{bodyClass "has-mobile-footer-nav"}}
    {{/if}}

    <div class="alt-mobile-nav">
      <SidebarsSidebar @showSearch={{true}} />
    </div>
  </template>
}
