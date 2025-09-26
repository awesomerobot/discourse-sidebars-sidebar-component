import { apiInitializer } from "discourse/lib/api";
import NotificationBell from "../components/notification-bell";

export default apiInitializer("1.15.0", (api) => {
  api.renderInOutlet("user-dropdown-button__before", NotificationBell);
});