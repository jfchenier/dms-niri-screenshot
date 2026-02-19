import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modules.Plugins
import qs.Widgets
import QtCore

PluginSettings {
    id: root
    pluginId: "dms-niri-screenshot"

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

    StyledText {
        width: parent.width
        text: "Niri Screenshot Settings"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Configure how screenshots are taken."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    SelectionSetting {
        settingKey: "mode"
        label: "Screenshot Mode"
        description: "Choose what to capture"
        options: [
            {label: "Interactive (UI)", value: "interactive"},
            {label: "Focused Window", value: "window"},
            {label: "Focused Screen", value: "screen"}
        ]
        defaultValue: "interactive"
    }

    ToggleSetting {
        settingKey: "showPointer"
        label: "Show Pointer"
        description: "Include mouse pointer in the screenshot"
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "saveToDisk"
        label: "Save to Disk"
        description: "Save screenshot to disk (only for Window/Screen modes)"
        defaultValue: true
    }
    
    StringSetting {
        id: customPathSetting
        settingKey: "customPath"
        label: "Custom Path"
        description: "Absolute path to save screenshots. Can be a directory or a file path. Leave empty for default."
        placeholder: root.niriDefaultPath
        defaultValue: ""
    }
}
