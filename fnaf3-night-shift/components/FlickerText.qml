import QtQuick 2.15

Text {
    id: root
    property real baseOpacity: 1.0
    property bool flickering: false
    color: "#e8e2f5"
    font.family: "Press Start 2P"
    font.pixelSize: 18
    opacity: baseOpacity

    Timer {
        interval: 60 + Math.random() * 140
        running: root.flickering
        repeat: true
        onTriggered: {
            interval = 60 + Math.random() * 140
            root.opacity = root.baseOpacity * (0.55 + Math.random() * 0.45)
        }
    }
}
