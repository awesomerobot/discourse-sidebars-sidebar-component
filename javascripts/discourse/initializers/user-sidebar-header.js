import { apiInitializer } from "discourse/lib/api";
import UserSidebarHeader from "../components/user-sidebar-header";

export default apiInitializer("1.15.0", (api) => {
  api.renderInOutlet("before-sidebar-sections", UserSidebarHeader);
});
