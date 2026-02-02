pragma Singleton
import QtQuick

QtObject {
    // Colors
    readonly property color bgDeep: "#0a0e1a"
    readonly property color bgSurface: "#111827"
    readonly property color bgCard: "#1a2332"
    readonly property color bgCardHover: "#243044"
    readonly property color accentBlue: "#3b82f6"
    readonly property color accentGlow: "#60a5fa"
    readonly property color accentCyan: "#22d3ee"
    readonly property color textPrimary: "#f1f5f9"
    readonly property color textSecondary: "#94a3b8"
    readonly property color textDim: "#64748b"
    readonly property color navBg: "#0f1629"
    readonly property color navActive: "#1e3a5f"
    readonly property color borderSubtle: "#1e293b"
    readonly property color dangerRed: "#ef4444"
    readonly property color successGreen: "#22c55e"
    readonly property color badgeSteam: "#1b2838"
    readonly property color badgeEpic: "#2a2a2a"
    readonly property color badgeXbox: "#107c10"
    readonly property color badgeNative: "#4a1d96"

    // Typography
    readonly property int fontSizeHuge: 42
    readonly property int fontSizeLarge: 28
    readonly property int fontSizeMedium: 18
    readonly property int fontSizeNormal: 15
    readonly property int fontSizeSmall: 12

    // Spacing
    readonly property int spacingXs: 4
    readonly property int spacingSm: 8
    readonly property int spacingMd: 16
    readonly property int spacingLg: 24
    readonly property int spacingXl: 32
    readonly property int spacingXxl: 48

    // Dimensions
    readonly property int navRailWidth: 72
    readonly property int tileWidth: 300
    readonly property int tileHeight: 170
    readonly property int listItemHeight: 64
    readonly property int iconSize: 28
    readonly property int borderRadius: 12
    readonly property int borderRadiusSm: 8

    // Animation
    readonly property int animFast: 150
    readonly property int animNormal: 250
    readonly property int animSlow: 400
    readonly property int animWarp: 300

    function sourceBadgeColor(source) {
        switch (source) {
            case "Steam": return badgeSteam;
            case "Epic": return badgeEpic;
            case "Xbox": return badgeXbox;
            case "GOG": return "#4a154b";
            default: return badgeNative;
        }
    }
}
