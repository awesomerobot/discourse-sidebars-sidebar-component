import { apiInitializer } from "discourse/lib/api";
import GroupsSidebarHeader from "../components/groups-sidebar-header";

export default apiInitializer("1.15.0", (api) => {
  api.renderInOutlet("before-sidebar-sections", GroupsSidebarHeader);
});