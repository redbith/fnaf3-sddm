import QtQuick 2.15

Item {
    id: root
    property real lineOpacity: 0.18
    property int lineSpacing: 3

    Canvas {
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.strokeStyle = "black"
            ctx.globalAlpha = root.lineOpacity
            ctx.lineWidth = 1
            for (var y = 0; y < height; y += root.lineSpacing) {
                ctx.beginPath()
                ctx.moveTo(0, y)
                ctx.lineTo(width, y)
                ctx.stroke()
            }
        }
    }

    // Faint vignette to darken the corners like an old monitor
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 0.75; color: "#00000000" }
            GradientStop { position: 1.0; color: "#aa000000" }
        }
    }
    Rectangle {
        anchors.fill: parent
        radius: 0
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "#55000000" }
            GradientStop { position: 0.12; color: "#00000000" }
            GradientStop { position: 0.88; color: "#00000000" }
            GradientStop { position: 1.0; color: "#55000000" }
        }
    }
}
