import QtQuick 2.15
import QtMultimedia

// Plays a local video file (with its own embedded audio track, if any) as a
// looping full-screen background. If videoSource is empty or the file can't
// be opened, this just renders nothing and the gradient/static behind it
// remains visible — so a missing file never breaks the greeter.
Item {
    id: root
    property url videoSource: ""
    property bool muted: false
    property real videoVolume: 0.6

    VideoOutput {
        id: videoOut
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
    }

    AudioOutput {
        id: audioOut
        muted: root.muted
        volume: root.videoVolume
    }

    MediaPlayer {
        id: player
        source: root.videoSource
        videoOutput: videoOut
        audioOutput: audioOut
        loops: MediaPlayer.Infinite

        onErrorOccurred: function(error, errorString) {
            console.log("[night-shift] video background could not be played:", errorString)
        }

        Component.onCompleted: {
            if (root.videoSource && root.videoSource.toString().length > 0) {
                play()
            }
        }
    }
}
