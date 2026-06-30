import QtQuick 2.15

// Pixelated TV static, redrawn on a timer. Drawing at a small internal
// resolution and scaling up keeps it cheap on the GPU/CPU while still
// looking like an old security camera feed losing signal.
Item {
    id: root
    property real noiseOpacity: 0.10
    property int intervalMs: 90
    property int internalWidth: 160
    property int internalHeight: 90

    Canvas {
        id: canvas
        anchors.fill: parent
        renderTarget: Canvas.FramebufferObject
        smooth: false

        property var imgData: null

        onPaint: {
            var ctx = getContext("2d")
            if (!imgData) {
                imgData = ctx.createImageData(internalWidth, internalHeight)
            }
            var data = imgData.data
            for (var i = 0; i < data.length; i += 4) {
                var v = Math.random() * 255
                data[i] = v
                data[i + 1] = v
                data[i + 2] = v
                data[i + 3] = 255
            }
            ctx.save()
            ctx.scale(width / internalWidth, height / internalHeight)
            ctx.putImageData(imgData, 0, 0)
            ctx.restore()
        }

        Timer {
            interval: root.intervalMs
            running: true
            repeat: true
            onTriggered: canvas.requestPaint()
        }
    }

    opacity: root.noiseOpacity
}
