import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

PluginSettings {
    id: root
    pluginId: "dms-niri-screenshot"

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
        description: "Save the screenshot to a file"
        defaultValue: true
    }
    
    StringSetting {
        settingKey: "customPath"
        label: "Custom Path"
        description: "Absolute path to save to (optional). Leave empty for default."
        placeholder: "/home/user/Pictures/Screenshots/shot.png"
        defaultValue: ""
    }
}
