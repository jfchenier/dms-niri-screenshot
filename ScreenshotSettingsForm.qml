import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets
import qs.Services

Column {
    id: root
    spacing: Theme.spacingM

    property string mode: "interactive"
    property bool showPointer: true
    property bool saveToDisk: true
    property string customPath: ""
    property string pluginId: ""
    signal saveSetting(string key, var value)



    // Mode Selection
    StyledRect {
        width: parent.width
        height: modeColumnCC.implicitHeight + Theme.spacingM * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHighest
        
        Column {
            id: modeColumnCC
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS
            
            StyledText {
                text: "Capture Mode"
                font.weight: Font.Bold
                color: Theme.surfaceText
            }
            
            Repeater {
                model: [
                    { label: "Interactive (UI)", value: "interactive", icon: "touch_app" },
                    { label: "Focused Window", value: "window", icon: "window" },
                    { label: "Focused Screen", value: "screen", icon: "monitor" }
                ]
                
                delegate: Rectangle {
                    width: parent.width
                    height: 40
                    radius: Theme.cornerRadius
                    color: root.mode === modelData.value ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1) : "transparent"
                    
                    RowLayout { 
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingS
                        anchors.rightMargin: Theme.spacingS
                        spacing: Theme.spacingM
                        
                        DankIcon {
                            name: modelData.icon
                            color: root.mode === modelData.value ? Theme.primary : Theme.surfaceVariantText
                            size: Theme.iconSize
                            Layout.alignment: Qt.AlignVCenter
                        }
                        
                        StyledText {
                            text: modelData.label
                            color: root.mode === modelData.value ? Theme.primary : Theme.surfaceText
                            font.weight: root.mode === modelData.value ? Font.Bold : Font.Normal
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true
                            verticalAlignment: Text.AlignVCenter 
                        }
                        
                        DankIcon {
                            visible: root.mode === modelData.value
                            name: "check"
                            color: Theme.primary
                            size: Theme.iconSize
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                    
                    MouseArea {
                        id: modeMA
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        preventStealing: true
                        onClicked: {
                            root.saveSetting("mode", modelData.value);
                        }
                    }
                }
            }
        }
    }

    // Options
    StyledRect {
        width: parent.width
        height: optionsColumnCC.implicitHeight + Theme.spacingM * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHighest
        
        Column {
            id: optionsColumnCC
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS
            
            StyledText {
                text: "Options"
                font.weight: Font.Bold
                color: Theme.surfaceText
            }

            // Show Pointer
            Rectangle {
                width: parent.width
                height: 40
                color: "transparent"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacingS
                    spacing: Theme.spacingM
                    
                    DankIcon {
                        name: root.showPointer ? "check_box" : "check_box_outline_blank"
                        color: root.showPointer ? Theme.primary : Theme.surfaceVariantText
                        size: Theme.iconSize
                        Layout.alignment: Qt.AlignVCenter
                    }
                    
                    StyledText {
                        text: "Show Pointer"
                        color: Theme.surfaceText
                        Layout.alignment: Qt.AlignVCenter
                        Layout.fillWidth: true
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    preventStealing: true
                    onClicked: {
                        root.saveSetting("showPointer", !root.showPointer);
                    }
                }
            }

            // Save to Disk
            Rectangle {
                width: parent.width
                height: 40
                color: "transparent"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacingS
                    spacing: Theme.spacingM
                    
                    DankIcon {
                        name: root.saveToDisk ? "check_box" : "check_box_outline_blank"
                        color: root.saveToDisk ? Theme.primary : Theme.surfaceVariantText
                        size: Theme.iconSize
                        Layout.alignment: Qt.AlignVCenter
                    }
                    
                    StyledText {
                        text: "Save to Disk"
                        color: Theme.surfaceText
                        Layout.alignment: Qt.AlignVCenter
                        Layout.fillWidth: true
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    preventStealing: true
                    onClicked: {
                        root.saveSetting("saveToDisk", !root.saveToDisk);
                    }
                }
            }
        }
    } 
    
    // Custom Path
    StyledRect {
        width: parent.width
        height: pathColumnCC.implicitHeight + Theme.spacingM * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHighest
        
        Column {
            id: pathColumnCC
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS
            
            StyledText {
                text: "Custom Path"
                font.weight: Font.Bold
                color: Theme.surfaceText
            }
            
            Rectangle {
                width: parent.width * 0.95
                height: 40
                color: Theme.background
                radius: Theme.cornerRadius
                border.color: pathInputCC.activeFocus ? Theme.primary : Theme.outline
                border.width: 1
                
                TextInput {
                    id: pathInputCC
                    anchors.fill: parent
                    anchors.margins: 8
                    text: root.customPath
                    color: Theme.surfaceText
                    font.pixelSize: Theme.fontSizeMedium
                    verticalAlignment: Text.AlignVCenter
                    clip: true
                    selectByMouse: true
                    
                    // Placeholder
                    Text {
                        text: "Default path..."
                        color: Theme.surfaceVariantText
                        visible: !parent.text && !parent.activeFocus
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: Theme.fontSizeMedium
                        leftPadding: 8
                    }

                    onEditingFinished: {
                        root.saveSetting("customPath", text);
                    }
                }
            }
        }
    }
}
