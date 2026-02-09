import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import QtQuick.Layouts

PluginComponent {
    id: root


    // -- Settings ----------------------------------------------------------------------
    property string mode: pluginData.mode || "interactive"
    property bool showPointer: pluginData.showPointer !== undefined ? pluginData.showPointer : true
    property bool saveToDisk: pluginData.saveToDisk !== undefined ? pluginData.saveToDisk : true

    // -- Internal ----------------------------------------------------------------------
    property bool isTakingScreenshot: false

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
             if (!root.showPointer) {
                niriArgs.push("--show-pointer=false");
            }
        }

        if (root.mode !== "interactive") {
            if (!root.saveToDisk) {
                niriArgs.push("--write-to-disk=false"); 
            }
        }


        // Construct the full command string for sh -c
        // We use a small sleep to allow the UI to close
        let fullCmd = "sleep 0.3; niri " + niriArgs.join(" ");
        let execCmd = ["sh", "-c", fullCmd];


        
        Quickshell.execDetached(execCmd);

        root.isTakingScreenshot = false;
        
        ToastService.showInfo("Screenshot", "Screenshot triggered");
    }

    // Required by PluginComponent, though we are mainly a CC widget.


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
                    
                    // Settings Content
                    // Settings Content
                    // Settings Content
                    ScreenshotSettingsForm {
                        id: settingsColumnCC
                        width: parent.width
                        
                        mode: root.mode
                        showPointer: root.showPointer
                        saveToDisk: root.saveToDisk
                        pluginId: pluginId
                        onSaveSetting: (key, value) => {
                            // Optimistic UI Update
                            if (key === "mode") root.mode = value;
                            if (key === "showPointer") root.showPointer = value;
                            if (key === "saveToDisk") root.saveToDisk = value;

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
                    
                    mode: root.mode
                    showPointer: root.showPointer
                    saveToDisk: root.saveToDisk
                    pluginId: pluginId
                    onSaveSetting: (key, value) => {
                        // Optimistic UI Update
                        if (key === "mode") root.mode = value;
                        if (key === "showPointer") root.showPointer = value;
                        if (key === "saveToDisk") root.saveToDisk = value;

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
