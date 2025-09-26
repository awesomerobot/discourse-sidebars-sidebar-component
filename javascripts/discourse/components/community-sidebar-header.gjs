import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { getOwner } from "@ember/owner";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import { service } from "@ember/service";
import { gt } from "truth-helpers";
import CreateTopicButton from "discourse/components/create-topic-button";

export default class CommunitySidebarHeader extends Component {
  @service router;
  @service currentUser;
  @service composer;

  @tracked category;
  @tracked tag;

  get shouldShow() {
    const currentRoute = this.router.currentRouteName;

    // Don't show on bot PMs
    if (currentRoute?.startsWith("topic.")) {
      const topicController = getOwner(this).lookup("controller:topic");
      const topic = topicController?.model;
      if (topic?.is_bot_pm) {
        return false;
      }
    }

    return currentRoute?.startsWith("discovery.") || currentRoute?.startsWith("tag.") || currentRoute?.startsWith("topic.");
  }

  get canCreateTopic() {
    return this.currentUser?.can_create_topic;
  }

  get draftCount() {
    return this.currentUser?.get("draft_count");
  }

  @action
  createTopic() {
    this.composer.openNewTopic({
      category: this.category,
      tags: this.tag?.id,
    });
  }

  @action
  getCategoryAndTag() {
    this.category = this.router.currentRoute.attributes?.category || null;
    this.tag = this.router.currentRoute.attributes?.tag || null;
  }

  <template>
    {{#if this.shouldShow}}
      <div
        class="community-sidebar-header"
        {{didInsert this.getCategoryAndTag}}
        {{didUpdate this.getCategoryAndTag this.router.currentRoute}}
      >
        <div class="community-sidebar-header__actions">
          <CreateTopicButton
            @canCreateTopic={{this.canCreateTopic}}
            @action={{this.createTopic}}
            @label="topic.create"
            @showDrafts={{gt this.draftCount 0}}
          />
        </div>
      </div>
    {{/if}}
  </template>
}