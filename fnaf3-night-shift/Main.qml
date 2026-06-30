import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import "components"

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: config.BackgroundColor || "#050308"

    readonly property color accent: config.AccentColor || "#7c2ae8"
    readonly property color danger: config.DangerColor || "#e63946"
    readonly property string pixelFont: config.FontFamily || "Press Start 2P"
    readonly property int nightNumber: config.NightNumber ? parseInt(config.NightNumber) : 3
    readonly property int introHoldMs: config.IntroDuration ? Math.max(500, parseInt(config.IntroDuration) * 1000 - 1800) : 2200

    FontLoader { id: pixelFontLoader; source: "fonts/PressStart2P-Regular.ttf" }

    property string uiState: "intro" // "intro" | "login"
    property int sessionIndex: 0
    property int userIndex: 0
    property string selectedUser: ""
    property string loginMessage: ""
    property bool loginFailedFlash: false

    // ---------- background ambience (always present) ----------
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.darker(root.accent, 6) }
            GradientStop { position: 1.0; color: "#000000" }
        }
        opacity: 0.9
    }

    // Looping menu-theme video, if one has been dropped into media/ — see
    // theme.conf's VideoSource key. Renders behind the static/scanline
    // overlay so it still reads as an old CRT/security feed.
    VideoBackground {
        anchors.fill: parent
        videoSource: config.VideoSource ? Qt.resolvedUrl(config.VideoSource) : ""
        muted: config.VideoMuted === "true"
        videoVolume: config.VideoVolume ? parseFloat(config.VideoVolume) : 0.6
    }

    StaticNoise {
        anchors.fill: parent
        noiseOpacity: root.uiState === "intro" ? 0.16 : 0.06
    }

    ScanLines {
        anchors.fill: parent
        lineOpacity: 0.16
    }

    // ---------- INTRO / SPLASH: "NIGHT X" start sequence ----------
    Item {
        id: introLayer
        anchors.fill: parent
        visible: opacity > 0.01
        opacity: 1

        Rectangle { anchors.fill: parent; color: "black"; opacity: 0.55 }

        Column {
            anchors.centerIn: parent
            spacing: 18

            FlickerText {
                id: nightLabel
                anchors.horizontalCenter: parent.horizontalCenter
                text: "NIGHT"
                font.pixelSize: 42
                font.family: pixelFontLoader.status === FontLoader.Ready ? pixelFontLoader.name : "monospace"
                color: "#e9e6da"
                opacity: 0
                scale: 0.8
            }

            FlickerText {
                id: nightNumberLabel
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.nightNumber.toString()
                font.pixelSize: 96
                font.family: pixelFontLoader.status === FontLoader.Ready ? pixelFontLoader.name : "monospace"
                color: root.accent
                opacity: 0
                scale: 0.8
            }

            FlickerText {
                id: subtitleLabel
                anchors.horizontalCenter: parent.horizontalCenter
                text: "SECURITY SHIFT INITIATED"
                font.pixelSize: 12
                font.family: pixelFontLoader.status === FontLoader.Ready ? pixelFontLoader.name : "monospace"
                color: "#8a9388"
                opacity: 0
            }
        }

        // quick bright flash used for the "static burst" transition out of intro
        Rectangle {
            id: flashRect
            anchors.fill: parent
            color: "white"
            opacity: 0
        }

        SequentialAnimation {
            id: introAnim
            running: true

            PauseAnimation { duration: 400 }

            ParallelAnimation {
                NumberAnimation { target: nightLabel; property: "opacity"; to: 1; duration: 550; easing.type: Easing.OutQuad }
                NumberAnimation { target: nightLabel; property: "scale"; to: 1; duration: 550; easing.type: Easing.OutBack }
            }

            PauseAnimation { duration: 250 }

            ParallelAnimation {
                NumberAnimation { target: nightNumberLabel; property: "opacity"; to: 1; duration: 500; easing.type: Easing.OutQuad }
                NumberAnimation { target: nightNumberLabel; property: "scale"; to: 1; duration: 500; easing.type: Easing.OutBack }
            }

            ScriptAction { script: nightNumberLabel.flickering = true }

            NumberAnimation { target: subtitleLabel; property: "opacity"; to: 1; duration: 600 }

            PauseAnimation { duration: root.introHoldMs }

            // static burst
            NumberAnimation { target: flashRect; property: "opacity"; to: 0.85; duration: 60 }
            NumberAnimation { target: flashRect; property: "opacity"; to: 0; duration: 220 }

            ParallelAnimation {
                NumberAnimation { target: introLayer; property: "opacity"; to: 0; duration: 500 }
                NumberAnimation { target: loginLayer; property: "opacity"; to: 1; duration: 600 }
            }

            ScriptAction { script: root.uiState = "login" }
        }
    }

    // ---------- LOGIN UI: security camera panel ----------
    Item {
        id: loginLayer
        anchors.fill: parent
        opacity: 0
        visible: opacity > 0.01

        // camera frame corner brackets
        Item {
            anchors.margins: 26
            anchors.fill: parent
            visible: config.ShowCameraFrame !== "false"

            Repeater {
                model: 4
                Item {
                    width: 34; height: 34
                    property bool isTop: index < 2
                    property bool isLeft: index % 2 === 0
                    x: isLeft ? 0 : parent.width - width
                    y: isTop ? 0 : parent.height - height
                    Rectangle { width: parent.width; height: 3; color: root.accent; y: isTop ? 0 : parent.height - height; opacity: 0.85 }
                    Rectangle { width: 3; height: parent.height; color: root.accent; x: isLeft ? 0 : parent.width - width; opacity: 0.85 }
                }
            }

            FlickerText {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 12
                text: "CAM 07 — OFFICE"
                font.pixelSize: 11
                font.family: "monospace"
                color: "#8fae9c"
            }

            Row {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 12
                spacing: 6
                Rectangle {
                    width: 8; height: 8; radius: 4; color: root.danger
                    anchors.verticalCenter: parent.verticalCenter
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.15; duration: 600 }
                        NumberAnimation { to: 1; duration: 600 }
                    }
                }
                Text { text: "REC"; color: root.danger; font.pixelSize: 11; font.family: "monospace" }
            }

            FlickerText {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.margins: 12
                id: clockLabel
                font.pixelSize: 11
                font.family: "monospace"
                color: "#8fae9c"
                text: Qt.formatDateTime(new Date(), "hh:mm:ss")
                Timer { interval: 1000; running: true; repeat: true; onTriggered: clockLabel.text = Qt.formatDateTime(new Date(), "hh:mm:ss") }
            }
        }

        // central login card — kept on the LEFT half of the screen and
        // vertically centered, so it doesn't sit on top of the right side
        // of the background video.
        Rectangle {
            id: card
            anchors.left: parent.left
            anchors.leftMargin: Math.max(60, parent.width * 0.06)
            anchors.verticalCenter: parent.verticalCenter
            width: 380
            height: cardColumn.implicitHeight + 60
            color: "#0b0d0a"
            opacity: 0.88
            border.color: root.accent
            border.width: 1
            radius: 4

            Column {
                id: cardColumn
                anchors.centerIn: parent
                width: parent.width - 60
                spacing: 16

                FlickerText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "NIGHT SHIFT"
                    font.pixelSize: 20
                    font.family: pixelFontLoader.status === FontLoader.Ready ? pixelFontLoader.name : "monospace"
                    color: root.accent
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: sddm.hostName !== undefined ? sddm.hostName : ""
                    color: "#7a8478"
                    font.pixelSize: 10
                    font.family: "monospace"
                }

                // ---- user selector ----
                // Built from delegates so we read role names ("name") the
                // way QML naturally exposes them, instead of guessing role
                // index numbers (those aren't guaranteed stable across
                // SDDM/Qt versions).
                Flow {
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    Repeater {
                        model: userModel
                        delegate: Rectangle {
                            width: userLabel.implicitWidth + 20
                            height: 28
                            radius: 2
                            color: index === root.userIndex ? root.accent : "#15170f"
                            border.color: index === root.userIndex ? root.accent : "#33392f"
                            border.width: 1
                            Component.onCompleted: if (index === 0) root.selectedUser = name
                            Text {
                                id: userLabel
                                anchors.centerIn: parent
                                text: name
                                font.pixelSize: 12
                                font.family: "monospace"
                                color: index === root.userIndex ? "#0b0d0a" : "#e9e6da"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { root.userIndex = index; root.selectedUser = name }
                            }
                        }
                    }
                }

                // ---- password ----
                TextField {
                    id: passwordField
                    width: parent.width
                    placeholderText: "PASSWORD"
                    echoMode: TextInput.Password
                    color: "#e9e6da"
                    font.family: "monospace"
                    horizontalAlignment: Text.AlignHCenter
                    background: Rectangle {
                        color: "#15170f"
                        border.color: passwordField.activeFocus ? root.accent : "#33392f"
                        border.width: 1
                        radius: 2
                    }
                    Keys.onReturnPressed: loginButton.doLogin()
                    Keys.onEnterPressed: loginButton.doLogin()
                    focus: root.uiState === "login"
                }

                // ---- session selector ----
                Flow {
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    Repeater {
                        model: sessionModel
                        delegate: Rectangle {
                            width: sessionLabel.implicitWidth + 16
                            height: 24
                            radius: 2
                            color: index === root.sessionIndex ? "#33392f" : "transparent"
                            border.color: "#33392f"
                            border.width: 1
                            Text {
                                id: sessionLabel
                                anchors.centerIn: parent
                                text: name
                                font.pixelSize: 10
                                font.family: "monospace"
                                color: index === root.sessionIndex ? root.accent : "#8a9388"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.sessionIndex = index
                            }
                        }
                    }
                }

                // ---- enter button ----
                Button {
                    id: loginButton
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "ENTER"
                    function doLogin() {
                        sddm.login(root.selectedUser, passwordField.text, root.sessionIndex)
                    }
                    onClicked: doLogin()
                    background: Rectangle {
                        implicitWidth: 140
                        implicitHeight: 34
                        color: loginButton.down ? Qt.darker(root.accent, 1.3) : root.accent
                        radius: 2
                    }
                    contentItem: Text {
                        text: loginButton.text
                        color: "#0b0d0a"
                        font.bold: true
                        font.family: "monospace"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                FlickerText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.loginMessage
                    color: root.danger
                    font.pixelSize: 12
                    font.family: "monospace"
                    visible: root.loginMessage.length > 0
                    flickering: root.loginFailedFlash
                }
            }
        }

        // power controls
        Row {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 20
            spacing: 14

            Text {
                text: "SUSPEND"
                color: "#7a8478"
                font.pixelSize: 10
                font.family: "monospace"
                visible: sddm.canSuspend
                MouseArea { anchors.fill: parent; onClicked: sddm.suspend() }
            }
            Text {
                text: "REBOOT"
                color: "#7a8478"
                font.pixelSize: 10
                font.family: "monospace"
                visible: sddm.canReboot
                MouseArea { anchors.fill: parent; onClicked: sddm.reboot() }
            }
            Text {
                text: "SHUTDOWN"
                color: root.danger
                font.pixelSize: 10
                font.family: "monospace"
                visible: sddm.canPowerOff
                MouseArea { anchors.fill: parent; onClicked: sddm.powerOff() }
            }
        }
    }

    Connections {
        target: sddm
        function onLoginSucceeded() {
            root.loginMessage = ""
        }
        function onLoginFailed() {
            root.loginMessage = "ACCESS DENIED — TRY AGAIN"
            root.loginFailedFlash = true
            passwordField.text = ""
        }
    }
}
