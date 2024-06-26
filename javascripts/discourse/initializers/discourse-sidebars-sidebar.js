import { apiInitializer } from "discourse/lib/api";
import SidebarsSidebar from "../components/sidebars-sidebar";

export default apiInitializer("1.15.0", (api) => {
  api.renderInOutlet("before-sidebar-sections", SidebarsSidebar);
});
