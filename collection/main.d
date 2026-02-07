module ui.main_window;

import gtk.MainWindow;
import ui.headerbar;

class MainWindow : MainWindow {
    this() {
        super("Podman Client");

        auto header = new PodmanHeaderBar();
        setTitlebar(header);

        // Connect menu actions
        header.menu.onPreferences = {
            showPreferences();
        };

        header.menu.onAbout = {
            showAboutDialog();
        };

        header.menu.onQuit = {
            this.destroy();
        };

        showAll();
    }

    void showPreferences() {
        // TODO: implement preferences window
    }

    void showAboutDialog() {
        // TODO: implement about dialog
    }
}