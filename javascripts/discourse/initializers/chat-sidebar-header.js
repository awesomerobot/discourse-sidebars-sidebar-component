import { apiInitializer } from "discourse/lib/api";
import ChatSidebarHeader from "../components/chat-sidebar-header";

export default apiInitializer("1.15.0", (api) => {
  api.renderInOutlet("before-sidebar-sections", ChatSidebarHeader);
});
