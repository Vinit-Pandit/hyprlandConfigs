import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Rectangle {
    id: confirmDialog
    visible: false
    z: 10000
    
    property string deviceName: "Unknown Device"
    property string passkey: "------"
    property var onConfirm: function() {}
    property var onCancel: function() {}
    
    anchors.fill: parent
    color: Qt.rgba(0, 0, 0, 0.7)
    
    function show(name, key) {
        deviceName = name
        passkey = key
        visible = true
    }
    
    function hide() {
        visible = false
    }
    
    MouseArea {
        anchors.fill: parent
        enabled: confirmDialog.visible
        onClicked: {} // Prevent clicks from passing through
    }
    
    Rectangle {
        anchors.centerIn: parent
        width: 360
        height: 280
        radius: 20
        color: root.walBackground
        border.color: root.walColor5
        border.width: 2
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20
            
            // Title
            Text {
                text: "󰂯 Bluetooth Pairing"
                color: root.walColor5
                font.pixelSize: 18
                font.bold: true
                font.family: "JetBrainsMono Nerd Font"
            }
            
            // Content
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 15
                
                Text {
                    text: "Device:"
                    color: root.walColor8
                    font.pixelSize: 11
                    font.family: "JetBrainsMono Nerd Font"
                }
                
                Text {
                    text: confirmDialog.deviceName
                    color: root.walForeground
                    font.pixelSize: 14
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                
                Item { Layout.fillHeight: true }
                
                Text {
                    text: "Confirm Passkey:"
                    color: root.walColor8
                    font.pixelSize: 11
                    font.family: "JetBrainsMono Nerd Font"
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    radius: 10
                    color: Qt.rgba(root.walColor5.r, root.walColor5.g, root.walColor5.b, 0.1)
                    border.color: root.walColor5
                    border.width: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: confirmDialog.passkey
                        color: root.walColor5
                        font.pixelSize: 32
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
                
                Item { Layout.fillHeight: true }
            }
            
            // Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    radius: 8
                    color: btCancelMa.containsMouse ? Qt.rgba(root.walColor1.r, root.walColor1.g, root.walColor1.b, 0.2) : Qt.rgba(root.walColor1.r, root.walColor1.g, root.walColor1.b, 0.1)
                    border.color: root.walColor1
                    border.width: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: "NO"
                        color: root.walColor1
                        font.pixelSize: 13
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    
                    MouseArea {
                        id: btCancelMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            confirmDialog.onCancel()
                            confirmDialog.hide()
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    radius: 8
                    color: btConfirmMa.containsMouse ? Qt.rgba(root.walColor2.r, root.walColor2.g, root.walColor2.b, 0.2) : Qt.rgba(root.walColor2.r, root.walColor2.g, root.walColor2.b, 0.1)
                    border.color: root.walColor2
                    border.width: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: "YES"
                        color: root.walColor2
                        font.pixelSize: 13
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    
                    MouseArea {
                        id: btConfirmMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            confirmDialog.onConfirm()
                            confirmDialog.hide()
                        }
                    }
                }
            }
        }
    }
}
