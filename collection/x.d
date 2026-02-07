module ui.main_window;

import gtk.MainWindow;
import ui.headerbar;
import ui.preferences_window;

class MainWindow : MainWindow {
    this() {
        super("Podman Client");

        auto header = new PodmanHeaderBar();
        setTitlebar(header);

        header.menu.onPreferences = {
            auto prefs = new PreferencesWindow(this);
            prefs.showAll();
        };

        showAll();
    }
}