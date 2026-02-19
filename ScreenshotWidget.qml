import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import QtQuick.Layouts
import QtCore

PluginComponent {
    id: root


    // -- Settings ----------------------------------------------------------------------
    property string mode: pluginData.mode || "interactive"
    property bool showPointer: pluginData.showPointer !== undefined ? pluginData.showPointer : true
    property bool saveToDisk: pluginData.saveToDisk !== undefined ? pluginData.saveToDisk : true
    property string customPath: pluginData.customPath || ""

    // -- Internal ----------------------------------------------------------------------
    property bool isTakingScreenshot: false
    property string niriDefaultPath: ""

    Process {
        id: defaultPathDetector
        command: ["sh", "-c", "file=$(grep -oP '(?<=screenshot-path \\\")[^\\\"]+' \"${XDG_CONFIG_HOME:-$HOME/.config}/niri/config.kdl\" 2>/dev/null); if [ -n \"$file\" ]; then echo \"${file/#$HOME/~}\"; else dir=$(xdg-user-dir PICTURES 2>/dev/null); if [ -n \"$dir\" ]; then echo \"${dir/#$HOME/~}/Screenshot %Y-%m-%d %H-%M-%S.png\"; else echo \"~/Pictures/Screenshot %Y-%m-%d %H-%M-%S.png\"; fi; fi"]
        running: true
        stdout: SplitParser {
            onRead: function(data) {
                if (data.trim() !== "") {
                    root.niriDefaultPath = data.trim();
                }
            }
        }
    }

    // Control Center Widget Properties
    ccWidgetIcon: "camera_enhance"
    ccWidgetPrimaryText: "Screenshot"
    ccWidgetSecondaryText: _getModeText()
    ccWidgetIsActive: false // Stateless action, so always inactive/ready

    function _getModeText() {
        if (root.mode === "interactive") return "Interactive Mode"
        if (root.mode === "window") return "Window Capture"
        if (root.mode === "screen") return "Screen Capture"
        return "Screenshot"
    }

    onCcWidgetToggled: {

        
        // Trigger screenshot first (spawns detached process with delay)
        takeScreenshot();

        // Then close the Control Center
        if (PopoutService) {
            PopoutService.closeControlCenter();
        }
    }

    function takeScreenshot() {
        if (root.isTakingScreenshot) return;
        root.isTakingScreenshot = true;

        // Reload settings from persistent storage to ensure we use the latest values
        if (typeof PluginService !== "undefined" && PluginService) {
            root.mode = PluginService.loadPluginData("dms-niri-screenshot", "mode", "interactive") || "interactive";
            root.showPointer = PluginService.loadPluginData("dms-niri-screenshot", "showPointer", true);
            root.saveToDisk = PluginService.loadPluginData("dms-niri-screenshot", "saveToDisk", true);
            root.customPath = PluginService.loadPluginData("dms-niri-screenshot", "customPath", "") || "";
        }

        let niriArgs = ["msg", "action"];
        
        // Base action
        if (root.mode === "window") {
            niriArgs.push("screenshot-window");
        } else if (root.mode === "screen") {
            niriArgs.push("screenshot-screen");
        } else {
            // interactive
            niriArgs.push("screenshot");
        }

        if (root.mode !== "window") {
            // screenshot and screenshot-screen support --show-pointer
            niriArgs.push("--show-pointer", root.showPointer ? "true" : "false");
        }

        // Write-to-disk (only for non-interactive modes)
        if (root.mode !== "interactive") {
            niriArgs.push("--write-to-disk", root.saveToDisk ? "true" : "false");
        }

        // Custom save path (only when saving to disk)
        if (root.saveToDisk && root.customPath) {
            let savePath = root.customPath;
            // If path doesn't end with an image extension, treat as directory
            if (!savePath.match(/\.(png|jpe?g)$/i)) {
                let now = new Date();
                let pad = function(n) { return String(n).padStart(2, '0'); };
                let ts = now.getFullYear() + "-" + pad(now.getMonth()+1) + "-" + pad(now.getDate())
                       + " " + pad(now.getHours()) + "-" + pad(now.getMinutes()) + "-" + pad(now.getSeconds());
                if (!savePath.endsWith("/")) savePath += "/";
                savePath += "Screenshot from " + ts + ".png";
            }
            niriArgs.push("--path", savePath);
        }



        // Construct the full command string for sh -c
        // We use a small sleep to allow the UI to close
        let fullCmd = "sleep 0.3; niri " + niriArgs.join(" ");
        let execCmd = ["sh", "-c", fullCmd];


        
        Quickshell.execDetached(execCmd);

        root.isTakingScreenshot = false;
        
        ToastService.showInfo("Screenshot", "Screenshot triggered");
    }


    // -- CC Detail Settings -------------------------------------------------------------
    ccDetailContent: Component {
        Rectangle {
            implicitHeight: 450
            radius: Theme.cornerRadius
            color: Theme.withAlpha(Theme.surfaceContainerHigh, Theme.popupTransparency)
            
            // Header
            StyledText {
                id: settingsHeader
                text: "Screenshot Settings"
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.surfaceText
                font.weight: Font.Medium
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: Theme.spacingM
            }

            DankButton {
                id: captureBtn
                anchors.right: parent.right
                anchors.verticalCenter: settingsHeader.verticalCenter
                anchors.rightMargin: Theme.spacingM
                height: 32
                width: 110
                text: "Capture"
                iconName: "camera_enhance"
                onClicked: {
                    root.takeScreenshot();
                    if (PopoutService) {
                        PopoutService.closeControlCenter();
                    }
                }
            }

            DankFlickable {
                anchors.top: settingsHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: Theme.spacingM
                contentHeight: settingsColumnCC.height
                clip: true

                    ScreenshotSettingsForm {
                        id: settingsColumnCC
                        width: parent.width
                        
                        pluginService: PluginService
                        pluginId: pluginId
                        niriDefaultPath: root.niriDefaultPath
                        onSaveSetting: function(key, value) {
                            // Optimistic UI Update
                            if (key === "mode") root.mode = value;
                            if (key === "showPointer") root.showPointer = value;
                            if (key === "saveToDisk") root.saveToDisk = value;
                            if (key === "customPath") root.customPath = value;

                            try {
                                if (typeof PluginService !== "undefined" && PluginService) {
                                     PluginService.savePluginData("dms-niri-screenshot", key, value);
                                } else if (root.pluginService) {
                                     root.pluginService.savePluginData("dms-niri-screenshot", key, value);
                                }
                            } catch (e) {
                                console.error("ScreenshotWidget: Save error:", e);
                            }
                        }
                    }
                }
            }
    }

    // -- Popout Settings ----------------------------------------------------------------
    popoutWidth: 320
    popoutHeight: 450
    

    
    popoutContent: Component {
        PopoutComponent {
            id: detailPopout
            headerText: "Screenshot Settings"
            detailsText: "Configure capture mode and options"
            showCloseButton: true
            
            Column {
                width: parent.width
                spacing: Theme.spacingM

                DankButton {
                    text: "Capture"
                    width: parent.width
                    height: 36
                    iconName: "camera_enhance"
                    onClicked: {
                        root.closePopout();
                        root.takeScreenshot();
                    }
                }

                ScreenshotSettingsForm {
                    width: parent.width
                    
                    pluginService: PluginService
                    pluginId: pluginId
                    niriDefaultPath: root.niriDefaultPath
                    onSaveSetting: function(key, value) {
                        // Optimistic UI Update
                        if (key === "mode") root.mode = value;
                        if (key === "showPointer") root.showPointer = value;
                        if (key === "saveToDisk") root.saveToDisk = value;
                        if (key === "customPath") root.customPath = value;

                        try {
                            if (typeof PluginService !== "undefined" && PluginService) {
                                 PluginService.savePluginData("dms-niri-screenshot", key, value);
                            } else if (root.pluginService) {
                                 root.pluginService.savePluginData("dms-niri-screenshot", key, value);
                            }
                        } catch (e) {
                            console.error("ScreenshotWidget: Popout save error:", e);
                        }
                    }
                }
            }
        }
    }

    // Required by PluginComponent, though we are mainly a CC widget.
    // We can provide a minimal bar widget if users enable it there.
    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS
            DankIcon {
                name: "camera_enhance"
                size: Theme.barIconSize(root.barThickness, -4)
                color: Theme.widgetIconColor
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS
            DankIcon {
                name: "camera_enhance"
                size: Theme.barIconSize(root.barThickness, -4)
                color: Theme.widgetIconColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
