module ui.hamburger_menu;

import gtk.MenuButton;
import gtk.Popover;
import gtk.Box;
import gtk.ModelButton;
import gtk.Image;

class HamburgerMenu : MenuButton {
    this() {
        super();

        // Hamburger icon
        setImage(new Image.fromIconName("open-menu-symbolic", 16));

        // Popover container
        auto pop = new Popover(this);
        auto box = new Box(Orientation.VERTICAL, 6);
        box.setMarginTop(6);
        box.setMarginBottom(6);
        box.setMarginStart(6);
        box.setMarginEnd(6);

        // Preferences
        auto prefs = new ModelButton();
        prefs.setText("Preferences");
        box.packStart(prefs, false, false, 0);

        // About
        auto about = new ModelButton();
        about.setText("About");
        box.packStart(about, false, false, 0);

        // Quit
        auto quit = new ModelButton();
        quit.setText("Quit");
        box.packStart(quit, false, false, 0);

        pop.add(box);
        setPopover(pop);

        // Signals
        prefs.addOnClicked(delegate { onPreferences(); });
        about.addOnClicked(delegate { onAbout(); });
        quit.addOnClicked(delegate { onQuit(); });
    }

    // Callbacks you can override in MainWindow
    void onPreferences() {}
    void onAbout() {}
    void onQuit() {}
}