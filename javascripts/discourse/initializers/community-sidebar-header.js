import { apiInitializer } from "discourse/lib/api";
import CommunitySidebarHeader from "../components/community-sidebar-header";

export default apiInitializer("1.15.0", (api) => {
  api.renderInOutlet("before-sidebar-sections", CommunitySidebarHeader);
});