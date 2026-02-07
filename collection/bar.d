module ui.headerbar;

import gtk.HeaderBar;
import gtk.Button;
import gtk.Image;
import ui.hamburger_menu;

class PodmanHeaderBar : HeaderBar {
    HamburgerMenu menu;

    this() {
        super();
        setShowCloseButton(true);
        setTitle("Podman Client");

        // Add hamburger menu on the right
        menu = new HamburgerMenu();
        packEnd(menu);

        // You can still add refresh/start/stop buttons here
    }
}