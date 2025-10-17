import { apiInitializer } from "discourse/lib/api";
import BreadcrumbFilterNavigation from "../components/breadcrumb-filter-navigation";

export default apiInitializer("1.15.0", (api) => {
  if (settings.replace_breadcrumb_with_filter) {
    api.renderInOutlet("after-breadcrumbs", BreadcrumbFilterNavigation);
  }
});
