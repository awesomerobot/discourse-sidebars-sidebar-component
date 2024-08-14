import { apiInitializer } from "discourse/lib/api";
import SidebarsSidebar from "../components/sidebars-sidebar";

export default apiInitializer("1.15.0", (api) => {
  if (!settings.mobile_footer_nav) {
    api.renderInOutlet("before-sidebar-sections", SidebarsSidebar);
  }
});
