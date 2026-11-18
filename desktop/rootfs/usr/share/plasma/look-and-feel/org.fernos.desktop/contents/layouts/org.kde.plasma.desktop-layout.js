// FernOS default Plasma layout.
// Runs once, the first time plasmashell starts for a user with no saved layout.
// Keep it minimal: one calm bottom panel, a few launchers, no widgets on the desktop.

var desktops = desktopsForActivity(currentActivity());
for (var i = 0; i < desktops.length; i++) {
    var d = desktops[i];
    d.wallpaperPlugin = "org.kde.image";
    d.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    d.writeConfig("Image", "file:///usr/share/wallpapers/Fern/");
    d.writeConfig("FillMode", "2"); // scaled and cropped
}

var panel = new Panel;
panel.location = "bottom";
panel.height = 2 * Math.floor(gridUnit * 2.5 / 2);
panel.floating = true;

var launcher = panel.addWidget("org.kde.plasma.kickoff");
launcher.currentConfigGroup = ["General"];
launcher.writeConfig("icon", "fernos");
launcher.writeConfig("favoritesPortedToKAstats", "true");

var tasks = panel.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", [
    "applications:org.kde.dolphin.desktop",
    "applications:zen.desktop",
    "applications:org.kde.konsole.desktop",
    "applications:code-oss.desktop",
    "applications:steam.desktop",
    "applications:fernblox.desktop",
    "applications:systemsettings.desktop"
]);

// One-click Game Mode / Work Mode switcher (fernos-modes).
// Left click opens the chooser; right click lists Game / Work / Normal directly.
var modes = panel.addWidget("org.kde.plasma.icon");
modes.currentConfigGroup = ["General"];
modes.writeConfig("url", "file:///usr/share/applications/org.fernos.modes.desktop");

panel.addWidget("org.kde.plasma.marginsseparator");
panel.addWidget("org.kde.plasma.systemtray");
panel.addWidget("org.kde.plasma.digitalclock");
panel.addWidget("org.kde.plasma.showdesktop");
