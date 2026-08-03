import QtQuick

import QGroundControl
import QGroundControl.Controls

Item {
    id: _root
    clip: true

    property Item pipView
    property Item pipState: videoPipState
    property int  _activeStream:   0
    property bool _showStreamMenu: false

    readonly property bool _isRtspSource: QGroundControl.settingsManager.videoSettings.videoSource.rawValue ===
                                          QGroundControl.settingsManager.videoSettings.rtspVideoSource

    PipState {
        id:         videoPipState
        pipView:    _root.pipView
        isDark:     true

        onWindowAboutToOpen: {
            QGroundControl.videoManager.stopVideo()
            videoStartDelay.start()
        }

        onWindowAboutToClose: {
            QGroundControl.videoManager.stopVideo()
            videoStartDelay.start()
        }

        onStateChanged: {
            if (pipState.state !== pipState.fullState) {
                QGroundControl.videoManager.fullScreen = false
            }
        }
    }

    Timer {
        id:           videoStartDelay
        interval:     2000;
        running:      false
        repeat:       false
        onTriggered:  QGroundControl.videoManager.startVideo()
    }

    //-- Video Streaming
    FlightDisplayViewVideo {
        id:             videoStreaming
        anchors.fill:   parent
        useSmallFont:   _root.pipState.state !== _root.pipState.fullState
        visible:        QGroundControl.videoManager.isStreamSource || QGroundControl.videoManager.isUvc
    }

    QGCLabel {
        text: qsTr("Double-click to exit full screen")
        font.pointSize: ScreenTools.largeFontPointSize
        visible: QGroundControl.videoManager.fullScreen
        anchors.centerIn: parent

        onVisibleChanged: {
            if (visible) {
                labelAnimation.start()
            }
        }

        PropertyAnimation on opacity {
            id: labelAnimation
            duration: 10000
            from: 1.0
            to: 0.0
            easing.type: Easing.InExpo
        }
    }

    OnScreenGimbalController {
        id:                      onScreenGimbalController
        anchors.fill:            parent
        cameraTrackingEnabled:   !!(videoStreaming._camera && videoStreaming._camera.trackingEnabled)
    }

    OnScreenCameraTrackingController {
        id:                      cameraTrackingController
        anchors.fill:            parent
        camera:                  videoStreaming._camera
        videoWidth:              videoStreaming.getWidth()
        videoHeight:             videoStreaming.getHeight()
    }

    MouseArea {
        id:                         flyViewVideoMouseArea
        anchors.fill:               parent
        enabled:                    pipState.state === pipState.fullState

        property real _pressX:      0
        property real _pressY:      0
        property bool _dragging:    false
        readonly property real _dragThreshold: 10

        onDoubleClicked: QGroundControl.videoManager.fullScreen = !QGroundControl.videoManager.fullScreen

        onPressed: (mouse) => {
            _pressX = mouse.x
            _pressY = mouse.y
            _dragging = false
        }

        onPositionChanged: (mouse) => {
            if (!_dragging && (Math.abs(mouse.x - _pressX) >= _dragThreshold || Math.abs(mouse.y - _pressY) >= _dragThreshold)) {
                _dragging = true
                onScreenGimbalController.mouseDragStart(_pressX, _pressY)
                cameraTrackingController.mouseDragStart(_pressX, _pressY)
            }
            if (_dragging) {
                onScreenGimbalController.mouseDragPositionChanged(mouse.x, mouse.y)
                cameraTrackingController.mouseDragPositionChanged(mouse.x, mouse.y)
            }
        }

        onReleased: (mouse) => {
            if (_dragging) {
                onScreenGimbalController.mouseDragEnd()
                cameraTrackingController.mouseDragEnd(mouse.x, mouse.y)
            } else {
                onScreenGimbalController.mouseClicked(mouse.x, mouse.y)
                cameraTrackingController.mouseClicked(mouse.x, mouse.y)
            }
            _dragging = false
        }
    }

    ProximityRadarVideoView {
        anchors.fill:   parent
        vehicle:        QGroundControl.multiVehicleManager.activeVehicle
    }

    ObstacleDistanceOverlayVideo {
        id:       obstacleDistance
        showText: pipState.state === pipState.fullState
    }

    // ── Stream selector toggle button ─────────────────────────────────
    Rectangle {
        id:             streamToggleBtn
        visible:        QGroundControl.videoManager.hasVideo && _isRtspSource
        z:              300
        anchors.top:    parent.top
        anchors.left:   parent.left
        anchors.topMargin:  pipState.state === pipState.fullState
                            ? ScreenTools.toolbarHeight * 1 + ScreenTools.defaultFontPixelHeight * 0.6
                            : ScreenTools.defaultFontPixelHeight * 0.4
        anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 0.6
        width:          streamRow.implicitWidth + ScreenTools.defaultFontPixelWidth * 3
        height:         ScreenTools.defaultFontPixelHeight * 1.8
        color:          Qt.rgba(0, 0, 0, 0.75)
        border.color:   Qt.rgba(1, 1, 1, 0.35)
        border.width:   1
        radius:         4

        Row {
            id:             streamRow
            anchors.centerIn: parent
            spacing:        ScreenTools.defaultFontPixelWidth * 0.5

            QGCLabel {
                id:             streamLabel
                text:           ["RGB", "Thermal", "IR"][_activeStream]
                color:          "white"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold:      true
            }
            QGCLabel {
                text:           _showStreamMenu ? "▲" : "▼"
                color:          Qt.rgba(1, 1, 1, 0.7)
                font.pointSize: ScreenTools.smallFontPointSize
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked:    _showStreamMenu = !_showStreamMenu
        }
    }

    // ── Dropdown panel ────────────────────────────────────────────────
    Rectangle {
        id:             streamDropdown
        visible:        _showStreamMenu && QGroundControl.videoManager.hasVideo && _isRtspSource
        z:              300
        anchors.top:    streamToggleBtn.bottom
        anchors.left:   streamToggleBtn.left
        anchors.topMargin: 3
        width:          Math.max(streamToggleBtn.width, ScreenTools.defaultFontPixelWidth * 16)
        height:         dropdownCol.implicitHeight + ScreenTools.defaultFontPixelHeight * 0.6
        color:          Qt.rgba(0.08, 0.08, 0.08, 0.92)
        border.color:   Qt.rgba(1, 1, 1, 0.25)
        border.width:   1
        radius:         4

        Column {
            id:             dropdownCol
            anchors.top:    parent.top
            anchors.left:   parent.left
            anchors.right:  parent.right
            anchors.margins: ScreenTools.defaultFontPixelHeight * 0.3
            spacing:        2

            Repeater {
                model: ["RGB", "Thermal", "IR"]
                delegate: Rectangle {
                    width:   dropdownCol.width
                    height:  ScreenTools.defaultFontPixelHeight * 2
                    radius:  3
                    color:   index === _activeStream
                             ? Qt.rgba(0.2, 0.5, 1.0, 0.55)
                             : (itemHover ? Qt.rgba(1, 1, 1, 0.12) : "transparent")

                    property bool itemHover: false

                    Rectangle {
                        width:   3
                        height:  parent.height * 0.6
                        radius:  2
                        anchors.left:           parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        color:   index === _activeStream ? "white" : "transparent"
                    }

                    QGCLabel {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left:           parent.left
                        anchors.leftMargin:     ScreenTools.defaultFontPixelWidth * 1.2
                        text:                   modelData
                        color:                  index === _activeStream ? "white" : Qt.rgba(1, 1, 1, 0.75)
                        font.pointSize:         ScreenTools.smallFontPointSize
                        font.bold:              index === _activeStream
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered:    parent.itemHover = true
                        onExited:     parent.itemHover = false
                        onClicked: {
                            _activeStream   = index
                            QGroundControl.videoManager.setActiveStreamIndex(index)
                            _showStreamMenu = false
                        }
                    }
                }
            }
        }
    }

    // ── Dismiss dropdown on outside click ─────────────────────────────
    MouseArea {
        anchors.fill: parent
        visible:      _showStreamMenu && _isRtspSource
        z:            299
        onClicked:    _showStreamMenu = false
    }
}
