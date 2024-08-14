import { apiInitializer } from "discourse/lib/api";
import AltMobileNav from "../components/alt-mobile-nav";

export default apiInitializer("1.15.0", (api) => {
  if (settings.mobile_footer_nav) {
    api.renderInOutlet("above-site-header", AltMobileNav);
  }
});
