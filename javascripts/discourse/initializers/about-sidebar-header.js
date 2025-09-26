import { apiInitializer } from "discourse/lib/api";
import AboutSidebarHeader from "../components/about-sidebar-header";

export default apiInitializer("1.15.0", (api) => {
  api.renderInOutlet("before-sidebar-sections", AboutSidebarHeader);
});