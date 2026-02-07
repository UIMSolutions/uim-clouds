module ui.about_dialog;

import gtk.AboutDialog;
import gtk.Window;

class AboutDialog {
    static void show(Window parent) {
        auto dialog = new AboutDialog();

        dialog.setProgramName("Podman Client");
        dialog.setVersion("0.1.0");
        dialog.setComments("A GTKD-based desktop client for managing Podman containers.");
        dialog.setWebsite("https://github.com/<yourname>/podman-d");
        dialog.setAuthors(["Ozan"]);
        dialog.setLicense("MIT License");

        dialog.setTransientFor(parent);
        dialog.run();
        dialog.destroy();
    }
}