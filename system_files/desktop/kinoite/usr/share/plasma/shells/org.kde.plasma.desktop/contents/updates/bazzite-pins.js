const allPanels = panels();

for (let i = 0; i < allPanels.length; ++i) {
    const panel = allPanels[i];
    const widgets = panel.widgets();

    for (let j = 0; j < widgets.length; ++j) {
        const widget = widgets[j];

        if (widget.type === "org.kde.plasma.icontasks") {
            widget.currentConfigGroup = ["General"];

            // Read the current launchers value
            const currentLaunchers = widget.readConfig("launchers", "");

            // Only set our default if launchers is empty
            if (!currentLaunchers || currentLaunchers.trim() === "") {
                widget.writeConfig("launchers", [
                    "preferred://browser",
                    "applications:steam.desktop",
                    "applications:net.lutris.Lutris.desktop",
                    "applications:org.kde.konsole.desktop",
                    "applications:io.github.kolunmi.Bazaar.desktop",
                    "preferred://filemanager"
                ]);
                widget.reloadConfig();
            }
        }
    }
}

