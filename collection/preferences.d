module ui.preferences_window;

import gtk.Window;
import gtk.HeaderBar;
import gtk.Box;
import gtk.Label;
import gtk.Switch;
import gtk.Separator;

class PreferencesWindow : Window {
    this(Window parent) {
        super("Preferences");

        setTransientFor(parent);
        setModal(true);
        setDefaultSize(400, 200);

        // HeaderBar
        auto header = new HeaderBar();
        header.setTitle("Preferences");
        header.setShowCloseButton(true);
        setTitlebar(header);

        // Main content box
        auto root = new Box(Orientation.VERTICAL, 12);
        root.setMarginTop(12);
        root.setMarginBottom(12);
        root.setMarginStart(12);
        root.setMarginEnd(12);
        add(root);

        // Example preference: auto-refresh
        auto row1 = new Box(Orientation.HORIZONTAL, 6);
        auto label1 = new Label("Auto-refresh container list");
        auto toggle1 = new Switch();
        row1.packStart(label1, false, false, 0);
        row1.packEnd(toggle1, false, false, 0);
        root.packStart(row1, false, false, 0);

        root.packStart(new Separator(Orientation.HORIZONTAL), false, false, 6);

        // Example preference: show logs on start
        auto row2 = new Box(Orientation.HORIZONTAL, 6);
        auto label2 = new Label("Show logs when selecting a container");
        auto toggle2 = new Switch();
        row2.packStart(label2, false, false, 0);
        row2.packEnd(toggle2, false, false, 0);
        root.packStart(row2, false, false, 0);

        showAll();
    }
}