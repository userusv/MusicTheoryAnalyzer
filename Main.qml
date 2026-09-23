import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    visible: true
    width: 1100
    height: 720
    minimumWidth: 900
    minimumHeight: 600
    title: "Music Theory Analyzer"
    color: "#111315"

    property string selectedMidiFile: ""
    property string currentPage: "overview"
    property real playheadTime: analyzer.playbackPosition

    FileDialog {
        id: midiFileDialog
        title: "Open MIDI File"
        nameFilters: [
            "MIDI files (*.mid *.midi)",
            "All files (*)"
        ]

        onAccepted: {
            selectedMidiFile = selectedFile.toString().replace("file://", "")
            analyzer.analyze(selectedMidiFile)
            currentPage = "overview"
        }
    }

    function sidebarColor(page) {
        return currentPage === page ? "#25292e" : "transparent"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 220
            Layout.fillHeight: true
            color: "#17191c"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 0

                Label {
                    text: "♪  ANALYZER"
                    color: "#f2f2f2"
                    font.pixelSize: 20
                    font.bold: true
                    Layout.bottomMargin: 45
                }

                Label {
                    text: "ANALYSIS"
                    color: "#70757d"
                    font.pixelSize: 11
                    font.bold: true
                    Layout.bottomMargin: 12
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 5
                    color: sidebarColor("overview")

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        text: "Overview"
                        color: "#ffffff"
                        font.pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: currentPage = "overview"
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 5
                    color: sidebarColor("melody")

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        text: "Melody"
                        color: "#a2a6ad"
                        font.pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: currentPage = "melody"
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 5
                    color: sidebarColor("harmony")

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        text: "Harmony"
                        color: "#a2a6ad"
                        font.pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: currentPage = "harmony"
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 5
                    color: sidebarColor("notes")

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        text: "Notes"
                        color: "#a2a6ad"
                        font.pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: currentPage = "notes"
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 5
                    color: sidebarColor("piano")

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        text: "Piano Roll"
                        color: "#a2a6ad"
                        font.pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: currentPage = "piano"
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                Label {
                    text: "FILE"
                    color: "#70757d"
                    font.pixelSize: 11
                    font.bold: true
                    Layout.bottomMargin: 12
                }

                Button {
                    text: "Open MIDI"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36

                    background: Rectangle {
                        radius: 5
                        color: parent.down ? "#30353b" :
                               parent.hovered ? "#2b3036" :
                               "#25292e"
                        border.color: "#343940"
                    }

                    contentItem: Label {
                        text: parent.text
                        color: "#eeeeee"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: midiFileDialog.open()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#111315"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 32
                spacing: 22

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: 4

                        Label {
                            text: currentPage === "overview" ? "Music Theory Analyzer" :
                                  currentPage === "melody" ? "Melody Analysis" :
                                  currentPage === "harmony" ? "Harmony Analysis" :
                                  currentPage === "notes" ? "Note Analysis" :
                                  "Piano Roll"
                            color: "#f3f3f3"
                            font.pixelSize: 28
                            font.bold: true
                        }

                        Label {
                            text: currentPage === "overview" ? "MIDI composition analysis" :
                                  currentPage === "melody" ? "Pitch and timing characteristics" :
                                  currentPage === "harmony" ? "Key and harmonic information" :
                                  currentPage === "notes" ? "Pitch-class distribution" :
                                  "MIDI note timeline"
                            color: "#777d85"
                            font.pixelSize: 14
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Label {
                        text: analyzer.status
                        color: "#777d85"
                        font.pixelSize: 12
                        elide: Text.ElideLeft
                        Layout.maximumWidth: 350
                    }
                }

                // OVERVIEW
                ColumnLayout {
                    visible: currentPage === "overview"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 22

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 108
                            radius: 7
                            color: "#191c20"
                            border.color: "#292d32"

                            Column {
                                anchors.fill: parent
                                anchors.margins: 18
                                spacing: 8

                                Label {
                                    text: "KEY"
                                    color: "#70767e"
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                Label {
                                    text: analyzer.key
                                    color: "#f4f4f4"
                                    font.pixelSize: 25
                                    font.bold: true
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 108
                            radius: 7
                            color: "#191c20"
                            border.color: "#292d32"

                            Column {
                                anchors.fill: parent
                                anchors.margins: 18
                                spacing: 8

                                Label {
                                    text: "DURATION"
                                    color: "#70767e"
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                Label {
                                    text: analyzer.duration.toFixed(1) + " sec"
                                    color: "#f4f4f4"
                                    font.pixelSize: 25
                                    font.bold: true
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 108
                            radius: 7
                            color: "#191c20"
                            border.color: "#292d32"

                            Column {
                                anchors.fill: parent
                                anchors.margins: 18
                                spacing: 8

                                Label {
                                    text: "NOTES"
                                    color: "#70767e"
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                Label {
                                    text: analyzer.totalNotes
                                    color: "#f4f4f4"
                                    font.pixelSize: 25
                                    font.bold: true
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 82
                            radius: 7
                            color: "#191c20"
                            border.color: "#292d32"

                            Column {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 5

                                Label {
                                    text: "TRACKS"
                                    color: "#70767e"
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                Label {
                                    text: analyzer.trackCount
                                    color: "#eeeeee"
                                    font.pixelSize: 21
                                    font.bold: true
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 82
                            radius: 7
                            color: "#191c20"
                            border.color: "#292d32"

                            Column {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 5

                                Label {
                                    text: "TEMPO"
                                    color: "#70767e"
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                Label {
                                    text: analyzer.tempo > 0 ? analyzer.tempo.toFixed(1) + " BPM" : "Not specified"
                                    color: "#eeeeee"
                                    font.pixelSize: 21
                                    font.bold: true
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 12

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 7
                            color: "#191c20"
                            border.color: "#292d32"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 22
                                spacing: 18

                                Label {
                                    text: "Melody Analysis"
                                    color: "#f2f2f2"
                                    font.pixelSize: 19
                                    font.bold: true
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 1
                                    color: "#292d32"
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    Label {
                                        text: "Average Pitch"
                                        color: "#858b93"
                                        font.pixelSize: 14
                                    }
                                    Item { Layout.fillWidth: true }
                                    Label {
                                        text: "MIDI " + analyzer.averagePitch.toFixed(2)
                                        color: "#eeeeee"
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    Label {
                                        text: "Average Note Duration"
                                        color: "#858b93"
                                        font.pixelSize: 14
                                    }
                                    Item { Layout.fillWidth: true }
                                    Label {
                                        text: analyzer.averageDuration.toFixed(2) + " sec"
                                        color: "#eeeeee"
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    Label {
                                        text: "Pitch Range"
                                        color: "#858b93"
                                        font.pixelSize: 14
                                    }
                                    Item { Layout.fillWidth: true }
                                    Label {
                                        text: analyzer.lowestPitch + " – " + analyzer.highestPitch
                                        color: "#eeeeee"
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                }

                                Item { Layout.fillHeight: true }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 7
                            color: "#191c20"
                            border.color: "#292d32"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 22
                                spacing: 15

                                Label {
                                    text: "Note Distribution"
                                    color: "#f2f2f2"
                                    font.pixelSize: 19
                                    font.bold: true
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 1
                                    color: "#292d32"
                                }

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Row {
                                        anchors.fill: parent
                                        anchors.bottomMargin: 24
                                        anchors.leftMargin: 4
                                        anchors.rightMargin: 4
                                        spacing: 7

                                        Repeater {
                                            model: 12

                                            Item {
                                                width: (parent.width - 77) / 12
                                                height: parent.height

                                                Rectangle {
                                                    width: parent.width
                                                    height: {
                                                        var maxValue = 1

                                                        for (var i = 0;
                                                             i < analyzer.noteFrequency.length;
                                                             i++) {
                                                            if (analyzer.noteFrequency[i].count > maxValue)
                                                                maxValue = analyzer.noteFrequency[i].count
                                                        }

                                                        return 120 *
                                                            (analyzer.noteFrequency[index].count / maxValue)
                                                    }

                                                    anchors.bottom: parent.bottom
                                                    radius: 3
                                                    color: "#8d9299"
                                                }

                                                Label {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    anchors.bottom: parent.bottom
                                                    anchors.bottomMargin: -22
                                                    text: [
                                                        "C", "C#", "D", "Eb", "E", "F",
                                                        "F#", "G", "Ab", "A", "Bb", "B"
                                                    ][index]
                                                    color: "#777d85"
                                                    font.pixelSize: 10
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // MELODY
                Rectangle {
                    visible: currentPage === "melody"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 7
                    color: "#191c20"
                    border.color: "#292d32"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 26
                        spacing: 22

                        Label {
                            text: "Melodic Characteristics"
                            color: "#f2f2f2"
                            font.pixelSize: 20
                            font.bold: true
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#292d32"
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 130
                                color: "#22262b"
                                radius: 6

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8

                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "AVERAGE PITCH"
                                        color: "#777d85"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }

                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "MIDI " + analyzer.averagePitch.toFixed(2)
                                        color: "#eeeeee"
                                        font.pixelSize: 25
                                        font.bold: true
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 130
                                color: "#22262b"
                                radius: 6

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8

                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "LOWEST NOTE"
                                        color: "#777d85"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }

                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: analyzer.lowestPitch
                                        color: "#eeeeee"
                                        font.pixelSize: 25
                                        font.bold: true
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 130
                                color: "#22262b"
                                radius: 6

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8

                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "HIGHEST NOTE"
                                        color: "#777d85"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }

                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: analyzer.highestPitch
                                        color: "#eeeeee"
                                        font.pixelSize: 25
                                        font.bold: true
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#292d32"
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            Label {
                                text: "Average note duration"
                                color: "#858b93"
                                font.pixelSize: 15
                            }

                            Item { Layout.fillWidth: true }

                            Label {
                                text: analyzer.averageDuration.toFixed(2) + " seconds"
                                color: "#eeeeee"
                                font.pixelSize: 15
                                font.bold: true
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            Label {
                                text: "Pitch range"
                                color: "#858b93"
                                font.pixelSize: 15
                            }

                            Item { Layout.fillWidth: true }

                            Label {
                                text: (analyzer.highestPitch - analyzer.lowestPitch) + " semitones"
                                color: "#eeeeee"
                                font.pixelSize: 15
                                font.bold: true
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }
                }

                // HARMONY
                Rectangle {
                    visible: currentPage === "harmony"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 7
                    color: "#191c20"
                    border.color: "#292d32"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 26
                        spacing: 18

                        RowLayout {
                            Layout.fillWidth: true

                            Label {
                                text: "Harmony"
                                color: "#f2f2f2"
                                font.pixelSize: 20
                                font.bold: true
                            }

                            Item { Layout.fillWidth: true }

                            Label {
                                text: analyzer.chordProgression.length + " segments"
                                color: "#777d85"
                                font.pixelSize: 12
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#292d32"
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 112
                            spacing: 12

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 6
                                color: "#22262b"
                                border.color: "#292d32"

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 7

                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "DETECTED KEY"
                                        color: "#777d85"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: analyzer.key
                                        color: "#eeeeee"
                                        font.pixelSize: 27
                                        font.bold: true
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 6
                                color: "#22262b"
                                border.color: "#292d32"

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 7

                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "TEMPO"
                                        color: "#777d85"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: analyzer.tempo > 0
                                              ? analyzer.tempo.toFixed(1) + " BPM"
                                              : "Not specified"
                                        color: "#eeeeee"
                                        font.pixelSize: 22
                                        font.bold: true
                                    }
                                }
                            }
                        }

                        Label {
                            text: "Chord timeline"
                            color: "#f2f2f2"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 82
                            radius: 6
                            color: "#22262b"
                            border.color: "#292d32"
                            clip: true

                            Item {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16

                                property real usableWidth: width
                                property real totalDuration: Math.max(0.001, analyzer.duration)

                                Repeater {
                                    model: analyzer.chordProgression

                                    delegate: Rectangle {
                                        property real segmentStart: Number(modelData.start)
                                        property real segmentEnd: Number(modelData.end)
                                        property real segmentDuration:
                                            Math.max(0.001, segmentEnd - segmentStart)

                                        x: segmentStart / parent.totalDuration * parent.usableWidth
                                        width: Math.max(
                                            4,
                                            segmentDuration / parent.totalDuration * parent.usableWidth - 2
                                        )
                                        y: 18
                                        height: 42
                                        radius: 4
                                        color: modelData.chord === "Uncertain"
                                               ? "#30353a" : "#8d9299"

                                        Label {
                                            anchors.centerIn: parent
                                            width: Math.max(1, parent.width - 8)
                                            text: String(modelData.chord)
                                            color: modelData.chord === "Uncertain"
                                                   ? "#aeb3b9" : "#111315"
                                            font.pixelSize: 11
                                            font.bold: true
                                            elide: Text.ElideRight
                                            horizontalAlignment: Text.AlignHCenter
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor

                                            ToolTip.visible: containsMouse
                                            ToolTip.delay: 150
                                            ToolTip.text:
                                                Number(modelData.start).toFixed(1)
                                                + " – "
                                                + Number(modelData.end).toFixed(1)
                                                + " sec | "
                                                + String(modelData.chord)

                                            onClicked: {
                                                analyzer.seekPlayback(Number(modelData.start))
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    visible: analyzer.duration > 0
                                    x: Math.max(
                                        0,
                                        Math.min(
                                            parent.width - 2,
                                            analyzer.playbackPosition
                                            / Math.max(0.001, analyzer.duration)
                                            * parent.width
                                        )
                                    )
                                    y: 10
                                    width: 2
                                    height: 58
                                    color: "#e4e6e9"
                                    z: 10
                                }

                                Label {
                                    anchors.centerIn: parent
                                    visible: chordList.count === 0
                                    text: "No chord progression available"
                                    color: "#777d85"
                                    font.pixelSize: 12
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            Label {
                                text: "0.0 s"
                                color: "#626870"
                                font.pixelSize: 10
                            }

                            Item { Layout.fillWidth: true }

                            Label {
                                text: analyzer.duration.toFixed(1) + " s"
                                color: "#626870"
                                font.pixelSize: 10
                            }
                        }

                        Label {
                            text: "Chord progression"
                            color: "#f2f2f2"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 6
                            color: "#22262b"
                            border.color: "#292d32"

                            ListView {
                                id: chordList
                                anchors.fill: parent
                                anchors.margins: 8
                                clip: true
                                spacing: 5
                                model: analyzer.chordProgression

                                delegate: Rectangle {
                                    width: ListView.view.width
                                    height: 42
                                    radius: 5
                                    color: "#191c20"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 12
                                        anchors.rightMargin: 12
                                        spacing: 10

                                        Label {
                                            text: Number(modelData.start).toFixed(1)
                                                + " – "
                                                + Number(modelData.end).toFixed(1)
                                                + " sec"
                                            color: "#777d85"
                                            font.pixelSize: 12
                                            Layout.preferredWidth: 120
                                        }

                                        Rectangle {
                                            width: 7
                                            height: 7
                                            radius: 3
                                            color: modelData.chord === "Uncertain"
                                                   ? "#5e646b" : "#d7dadd"
                                        }

                                        Label {
                                            text: String(modelData.chord)
                                            color: "#eeeeee"
                                            font.pixelSize: 14
                                            font.bold: true
                                            Layout.fillWidth: true
                                        }

                                        Button {
                                            text: "Play"
                                            Layout.preferredWidth: 52
                                            Layout.preferredHeight: 26

                                            background: Rectangle {
                                                radius: 4
                                                color: parent.hovered ? "#2b3036" : "#202429"
                                                border.color: "#343940"
                                            }

                                            contentItem: Label {
                                                text: parent.text
                                                color: "#bfc3c8"
                                                font.pixelSize: 11
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            onClicked: {
                                                analyzer.seekPlayback(Number(modelData.start))
                                                analyzer.playPlayback()
                                            }
                                        }
                                    }
                                }

                                Label {
                                    anchors.centerIn: parent
                                    visible: chordTimeline.count === 0
                                    text: "No chord progression available"
                                    color: "#777d85"
                                    font.pixelSize: 12
                                }
                            }
                        }
                    }
                }

                // NOTES
                Rectangle {
                    visible: currentPage === "notes"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 7
                    color: "#191c20"
                    border.color: "#292d32"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 26
                        spacing: 18

                        Label {
                            text: "Note Frequency"
                            color: "#f2f2f2"
                            font.pixelSize: 20
                            font.bold: true
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#292d32"
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 18

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 6
                                color: "#22262b"
                                border.color: "#292d32"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 20
                                    spacing: 12

                                    RowLayout {
                                        Layout.fillWidth: true

                                        Label {
                                            text: "Pitch-class distribution"
                                            color: "#eeeeee"
                                            font.pixelSize: 15
                                            font.bold: true
                                        }

                                        Item { Layout.fillWidth: true }

                                        Label {
                                            text: analyzer.totalNotes + " notes"
                                            color: "#777d85"
                                            font.pixelSize: 12
                                        }
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        Row {
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8
                                            anchors.topMargin: 12
                                            anchors.bottomMargin: 28
                                            spacing: 8

                                            Repeater {
                                                model: 12

                                                Item {
                                                    width: (parent.width - 88) / 12
                                                    height: parent.height

                                                    property int noteCount: index < analyzer.noteFrequency.length
                                                        ? analyzer.noteFrequency[index].count : 0

                                                    property int maxCount: {
                                                        var maxValue = 1
                                                        for (var i = 0; i < analyzer.noteFrequency.length; ++i)
                                                            maxValue = Math.max(maxValue, analyzer.noteFrequency[i].count)
                                                        return maxValue
                                                    }

                                                    Rectangle {
                                                        anchors.left: parent.left
                                                        anchors.right: parent.right
                                                        anchors.bottom: parent.bottom
                                                        height: parent.height * (parent.noteCount / parent.maxCount)
                                                        radius: 3
                                                        color: "#8d9299"
                                                    }

                                                    Label {
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        anchors.bottom: parent.bottom
                                                        anchors.bottomMargin: 4
                                                        text: parent.noteCount
                                                        color: "#eeeeee"
                                                        font.pixelSize: 11
                                                        font.bold: true
                                                        visible: parent.noteCount > 0
                                                    }

                                                    Label {
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        anchors.bottom: parent.bottom
                                                        anchors.bottomMargin: -23
                                                        text: [
                                                            "C", "C#", "D", "Eb", "E", "F",
                                                            "F#", "G", "Ab", "A", "Bb", "B"
                                                        ][index]
                                                        color: "#777d85"
                                                        font.pixelSize: 10
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 245
                                Layout.fillHeight: true
                                radius: 6
                                color: "#22262b"
                                border.color: "#292d32"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 20
                                    spacing: 10

                                    Label {
                                        text: "Note counts"
                                        color: "#eeeeee"
                                        font.pixelSize: 15
                                        font.bold: true
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 1
                                        color: "#292d32"
                                    }

                                    ListView {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        clip: true
                                        spacing: 5
                                        model: 12

                                        delegate: RowLayout {
                                            width: ListView.view.width
                                            height: 26
                                            spacing: 8

                                            Label {
                                                text: [
                                                    "C", "C#", "D", "Eb", "E", "F",
                                                    "F#", "G", "Ab", "A", "Bb", "B"
                                                ][index]
                                                color: "#aeb3b9"
                                                font.pixelSize: 12
                                                Layout.preferredWidth: 28
                                            }

                                            Item { Layout.fillWidth: true }

                                            Label {
                                                text: index < analyzer.noteFrequency.length
                                                    ? String(analyzer.noteFrequency[index].count) : "0"
                                                color: "#eeeeee"
                                                font.pixelSize: 12
                                                font.bold: true
                                                Layout.preferredWidth: 30
                                                horizontalAlignment: Text.AlignRight
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // PIANO ROLL
                Rectangle {
                    visible: currentPage === "piano"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 7
                    color: "#191c20"
                    border.color: "#292d32"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 22
                        spacing: 12

                        RowLayout {
                            Layout.fillWidth: true

                            Label {
                                text: "MIDI Piano Roll"
                                color: "#f2f2f2"
                                font.pixelSize: 20
                                font.bold: true
                            }

                            Item { Layout.fillWidth: true }

                            Label {
                                text: "Key: " + analyzer.key
                                color: "#8f959d"
                                font.pixelSize: 12
                            }

                            Label {
                                text: analyzer.totalNotes + " notes"
                                color: "#777d85"
                                font.pixelSize: 12
                                Layout.leftMargin: 16
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Button {
                                text: analyzer.playing ? "Pause" : "Play"
                                Layout.preferredWidth: 72
                                Layout.preferredHeight: 30
                                background: Rectangle {
                                    radius: 4
                                    color: parent.down ? "#30353b" : parent.hovered ? "#2b3036" : "#25292e"
                                    border.color: "#343940"
                                }
                                contentItem: Label {
                                    text: parent.text
                                    color: "#eeeeee"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    if (analyzer.duration <= 0) return
                                    if (analyzer.playing)
                                        analyzer.pausePlayback()
                                    else
                                        analyzer.playPlayback()
                                }
                            }

                            Button {
                                text: "Reset"
                                Layout.preferredWidth: 62
                                Layout.preferredHeight: 30
                                background: Rectangle {
                                    radius: 4
                                    color: parent.hovered ? "#2b3036" : "#202429"
                                    border.color: "#30353b"
                                }
                                contentItem: Label {
                                    text: parent.text
                                    color: "#bfc3c8"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    analyzer.stopPlayback()
                                }
                            }

                            Label {
                                text: "Zoom"
                                color: "#777d85"
                                font.pixelSize: 12
                                Layout.leftMargin: 12
                            }

                            Slider {
                                id: zoomSlider
                                from: 0.75
                                to: 2.0
                                value: 1.0
                                stepSize: 0.05
                                Layout.preferredWidth: 150
                            }

                            Label {
                                text: Math.round(zoomSlider.value * 100) + "%"
                                color: "#9da2a8"
                                font.pixelSize: 12
                                Layout.preferredWidth: 42
                            }

                            Item { Layout.fillWidth: true }

                            Label {
                                text: playheadTime.toFixed(2) + " s"
                                color: "#9da2a8"
                                font.pixelSize: 12
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 5
                            color: "#111315"
                            border.color: "#292d32"
                            clip: true

                            Item {
                                id: pianoCanvas
                                anchors.fill: parent

                                property real keyboardWidth: 62
                                property real timeAxisHeight: 28
                                property real rowHeight: 12
                                property real basePixelsPerSecond: Math.max(35, (width - keyboardWidth) / Math.max(1, analyzer.duration))
                                property real pixelsPerSecond: basePixelsPerSecond * zoomSlider.value

                                property int minPitch: {
                                    if (analyzer.noteTimeline.length === 0) return 48
                                    var minP = 127
                                    for (var i = 0; i < analyzer.noteTimeline.length; i++) minP = Math.min(minP, analyzer.noteTimeline[i].pitch)
                                    return Math.floor(minP / 12) * 12
                                }

                                property int maxPitch: {
                                    if (analyzer.noteTimeline.length === 0) return 72
                                    var maxP = 0
                                    for (var i = 0; i < analyzer.noteTimeline.length; i++) maxP = Math.max(maxP, analyzer.noteTimeline[i].pitch)
                                    return Math.ceil((maxP + 1) / 12) * 12
                                }

                                function noteName(pitch) {
                                    var names = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
                                    return names[((pitch % 12) + 12) % 12]
                                }

                                function keyTone(pitch) {
                                    var key = analyzer.key
                                    if (!key || key === "No analysis") return true

                                    var names = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
                                    var root = names.indexOf(key.split(" ")[0])
                                    if (root < 0) return true

                                    var intervals = key.indexOf("Minor") >= 0 ? [0, 2, 3, 5, 7, 8, 10] : [0, 2, 4, 5, 7, 9, 11]
                                    var pc = ((pitch % 12) + 12) % 12
                                    return intervals.indexOf((pc - root + 12) % 12) >= 0
                                }

                                function chordAt(time) {
                                    for (var i = 0; i < analyzer.chordProgression.length; i++) {
                                        var chord = analyzer.chordProgression[i]
                                        if (time >= chord.start && time < chord.end) return chord.chord
                                    }
                                    return "Uncertain"
                                }

                                function chordTone(pitch, time) {
                                    var chord = chordAt(time)
                                    if (!chord || chord === "Uncertain") return false

                                    var names = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
                                    var rootName = chord.split(" ")[0]
                                    var root = names.indexOf(rootName)
                                    if (root < 0) return false

                                    var intervals = chord.indexOf("dim") >= 0 ? [0, 3, 6] :
                                                    chord.indexOf("min") >= 0 ? [0, 3, 7] :
                                                    [0, 4, 7]

                                    var pc = ((pitch % 12) + 12) % 12
                                    return intervals.indexOf((pc - root + 12) % 12) >= 0
                                }

                                Rectangle {
                                    x: 0
                                    y: 0
                                    width: pianoCanvas.keyboardWidth
                                    height: pianoCanvas.height - pianoCanvas.timeAxisHeight
                                    color: "#17191c"
                                }

                                Repeater {
                                    model: Math.max(1, pianoCanvas.maxPitch - pianoCanvas.minPitch)
                                    Rectangle {
                                        x: pianoCanvas.keyboardWidth
                                        y: index * pianoCanvas.rowHeight
                                        width: Math.max(0, pianoCanvas.width - pianoCanvas.keyboardWidth)
                                        height: 1
                                        color: ((pianoCanvas.maxPitch - 1 - index) % 12 === 0) ? "#343940" : "#22262b"
                                    }
                                }

                                Repeater {
                                    model: Math.max(1, pianoCanvas.maxPitch - pianoCanvas.minPitch)
                                    Label {
                                        x: 5
                                        y: index * pianoCanvas.rowHeight
                                        width: pianoCanvas.keyboardWidth - 9
                                        height: pianoCanvas.rowHeight
                                        text: pianoCanvas.noteName(pianoCanvas.maxPitch - 1 - index) + "" + (Math.floor((pianoCanvas.maxPitch - 1 - index) / 12) - 1)
                                        color: ((pianoCanvas.maxPitch - 1 - index) % 12 === 0) ? "#d6d9dd" : "#626870"
                                        font.pixelSize: 9
                                        horizontalAlignment: Text.AlignRight
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Repeater {
                                    model: analyzer.noteTimeline
                                    Rectangle {
                                        property int pitch: modelData.pitch
                                        property bool inKey: pianoCanvas.keyTone(pitch)
                                        property bool inChord: pianoCanvas.chordTone(pitch, modelData.start)
                                        x: pianoCanvas.keyboardWidth + modelData.start * pianoCanvas.pixelsPerSecond
                                        y: (pianoCanvas.maxPitch - 1 - pitch) * pianoCanvas.rowHeight
                                        width: Math.max(6, (modelData.end - modelData.start) * pianoCanvas.pixelsPerSecond)
                                        height: Math.max(7, pianoCanvas.rowHeight - 2)
                                        radius: 2
                                        color: noteMouse.containsMouse ? "#ffffff" : inChord ? "#d7dadd" : inKey ? "#9da3aa" : "#5e646b"
                                        border.width: noteMouse.containsMouse ? 1 : 0
                                        border.color: "#ffffff"

                                        MouseArea {
                                            id: noteMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            ToolTip.visible: containsMouse
                                            ToolTip.delay: 150
                                            ToolTip.text: pianoCanvas.noteName(modelData.pitch) + " | MIDI " + String(modelData.pitch) +
                                                           "\nStart: " + Number(modelData.start).toFixed(2) + " s" +
                                                           "\nDuration: " + Number(modelData.end - modelData.start).toFixed(2) + " s" +
                                                           "\nKey: " + (inKey ? "diatonic" : "chromatic") +
                                                           "\nChord: " + String(pianoCanvas.chordAt(modelData.start))
                                            onClicked: {
                                                analyzer.seekPlayback(modelData.start)
                                            }
                                        }
                                    }
                                }

                                Repeater {
                                    model: Math.max(1, Math.ceil(Math.max(1, analyzer.duration) + 1))
                                    Rectangle {
                                        x: pianoCanvas.keyboardWidth + index * pianoCanvas.pixelsPerSecond
                                        y: 0
                                        width: 1
                                        height: pianoCanvas.height - pianoCanvas.timeAxisHeight
                                        color: index === 0 ? "#343940" : "#202429"
                                    }
                                }

                                Repeater {
                                    model: Math.max(1, Math.ceil(Math.max(1, analyzer.duration) + 1))
                                    Label {
                                        x: pianoCanvas.keyboardWidth + index * pianoCanvas.pixelsPerSecond + 5
                                        y: pianoCanvas.height - pianoCanvas.timeAxisHeight + 7
                                        text: index + "s"
                                        color: "#626870"
                                        font.pixelSize: 9
                                    }
                                }

                                Rectangle {
                                    x: pianoCanvas.keyboardWidth + playheadTime * pianoCanvas.pixelsPerSecond
                                    y: 0
                                    width: 2
                                    height: pianoCanvas.height - pianoCanvas.timeAxisHeight
                                    color: "#e4e6e9"
                                    visible: analyzer.duration > 0
                                    z: 10
                                }

                                MouseArea {
                                    anchors.left: parent.left
                                    anchors.leftMargin: pianoCanvas.keyboardWidth
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    z: -1
                                    onClicked: function(mouse) {
                                        var time = mouse.x / pianoCanvas.pixelsPerSecond
                                        analyzer.seekPlayback(time)
                                    }
                                }

                                Row {
                                    x: pianoCanvas.keyboardWidth + 10
                                    y: pianoCanvas.height - pianoCanvas.timeAxisHeight + 5
                                    spacing: 12

                                    Rectangle { width: 8; height: 8; radius: 2; color: "#d7dadd"; anchors.verticalCenter: parent.verticalCenter }
                                    Label { text: "Chord"; color: "#626870"; font.pixelSize: 9 }
                                    Rectangle { width: 8; height: 8; radius: 2; color: "#9da3aa"; anchors.verticalCenter: parent.verticalCenter }
                                    Label { text: "Key"; color: "#626870"; font.pixelSize: 9 }
                                    Rectangle { width: 8; height: 8; radius: 2; color: "#5e646b"; anchors.verticalCenter: parent.verticalCenter }
                                    Label { text: "Chromatic"; color: "#626870"; font.pixelSize: 9 }
                                }

                                Rectangle {
                                    x: 0
                                    y: pianoCanvas.height - pianoCanvas.timeAxisHeight
                                    width: pianoCanvas.width
                                    height: 1
                                    color: "#343940"
                                }

                                Label {
                                    x: 8
                                    y: pianoCanvas.height - pianoCanvas.timeAxisHeight + 7
                                    text: "TIME"
                                    color: "#626870"
                                    font.pixelSize: 9
                                    font.bold: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
}
}
