import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

ApplicationWindow {
    id: window

    width: 1280
    height: 840

    minimumWidth: 760
    minimumHeight: 620

    visible: true
    title: "Daylight — Daily Planner"
    color: "#f4f6f8"

    font.family: "DejaVu Sans"
    font.pixelSize: 14

    readonly property color ink: "#18293a"
    readonly property color muted: "#75818e"
    readonly property color accent: "#234e47"

    property string editingId: ""
    property string deletingId: ""

    property int activeFilter: 0

    function openEditor(task) {
        taskManager.clearError()

        editingId = task ? task.id : ""

        titleInput.text = task ? task.title : ""
        notesInput.text = task ? task.notes : ""

        dateInput.text = task
            ? task.date
            : taskManager.selectedDate

        timeInput.text = task ? task.time : ""

        priorityInput.currentIndex = task
            ? task.priority
            : 1

        editor.open()
        titleInput.forceActiveFocus()
    }

    Shortcut {
        sequence: "Ctrl+N"
        onActivated: window.openEditor(null)
    }

    Shortcut {
        sequence: "Ctrl+F"
        onActivated: search.forceActiveFocus()
    }

    component ActionButton: Button {
        id: action

        property bool primary: false
        property bool destructive: false

        implicitHeight: 42

        leftPadding: 18
        rightPadding: 18

        font.bold: true

        contentItem: Text {
            text: action.text
            font: action.font

            color: action.primary
                ? "white"
                : action.destructive
                  ? "#b94b4b"
                  : window.ink

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            radius: 12

            color: action.primary
                ? (action.hovered ? "#30675c" : window.accent)
                : (action.hovered ? "#e4e9ed" : "#eef1f4")

            border.color: action.activeFocus
                ? "#40a68d"
                : "transparent"

            border.width: 2
        }
    }

    component Input: TextField {
        implicitHeight: 46

        color: window.ink
        selectByMouse: true

        padding: 12

        background: Rectangle {
            radius: 10
            color: "#f4f6f8"

            border.color: parent.activeFocus
                ? "#3f8b78"
                : "#dce3e8"
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            visible: window.width >= 1050

            Layout.preferredWidth: 238
            Layout.fillHeight: true

            color: "#152b35"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 25

                spacing: 26

                RowLayout {
                    spacing: 10

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 11

                        color: "#c3ebda"

                        Text {
                            anchors.centerIn: parent

                            text: "D"

                            font.bold: true
                            font.pixelSize: 22

                            color: "#193d35"
                        }
                    }

                    Text {
                        text: "daylight"
                        color: "#ffffff"

                        font.pixelSize: 25
                        font.bold: true
                    }
                }

                Text {
                    text: "A LITTLE STRUCTURE.\nA LOT MORE SPACE."

                    color: "#86a1ab"

                    font.pixelSize: 10
                    font.letterSpacing: 1.6

                    lineHeight: 1.7
                }

                Rectangle {
                    Layout.fillWidth: true

                    height: 49
                    radius: 12

                    color: "#28434c"

                    Text {
                        anchors.centerIn: parent

                        text: "◷   Daily planner"
                        color: "#d5f4e6"

                        font.bold: true
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                Rectangle {
                    Layout.fillWidth: true

                    implicitHeight: 176
                    radius: 16

                    color: "#223c45"

                    Column {
                        anchors.fill: parent
                        anchors.margins: 17

                        spacing: 12

                        Text {
                            text: "MAKE ROOM"

                            color: "#a5d7c3"

                            font.pixelSize: 10
                            font.letterSpacing: 2
                        }

                        Text {
                            width: parent.width

                            text: "Small steps.\nClearer days."
                            color: "white"

                            font.pixelSize: 23
                            font.bold: true

                            lineHeight: 1.15
                        }

                        Text {
                            text: "One task at a time."
                            color: "#91aab2"

                            font.pixelSize: 11
                        }
                    }
                }

                Text {
                    text: "LOCAL & PRIVATE  /  v1.0"

                    color: "#78949e"

                    font.pixelSize: 9
                    font.letterSpacing: 1
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.margins: window.width < 900 ? 24 : 38

            spacing: 22

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 7

                    Text {
                        text: "YOUR DAILY SPACE"
                        color: window.muted

                        font.pixelSize: 10
                        font.letterSpacing: 2
                    }

                    Text {
                        text: "A day with intention."
                        color: window.ink

                        font.pixelSize: 30
                        font.bold: true
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                ActionButton {
                    text: "+  New task"

                    primary: true

                    onClicked: window.openEditor(null)
                }
            }

            Rectangle {
                Layout.fillWidth: true

                implicitHeight: 142
                radius: 22

                color: "#dceee5"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 23

                    spacing: 20

                    ColumnLayout {
                        Layout.fillWidth: true

                        spacing: 10

                        Text {
                            text: "FOCUS ON WHAT MATTERS"

                            color: "#477364"

                            font.pixelSize: 10
                            font.letterSpacing: 1.5
                        }

                        Text {
                            text: taskManager.total === 0
                                ? "Your day, a fresh start."
                                : taskManager.completed === taskManager.total
                                  ? "Everything is checked off."
                                  : "You've got this."

                            color: "#203e34"

                            font.pixelSize: 23
                            font.bold: true
                        }

                        Text {
                            text: "Plan a little. Make progress. Leave room to breathe."

                            color: "#547567"

                            font.pixelSize: 12
                        }
                    }

                    ColumnLayout {
                        Layout.preferredWidth: 145

                        spacing: 10

                        Text {
                            text: taskManager.completed
                                + " / "
                                + taskManager.total

                            color: "#244c3d"

                            font.pixelSize: 30
                            font.bold: true
                        }

                        Text {
                            text: "tasks completed"
                            color: "#547567"

                            font.pixelSize: 11
                        }

                        Rectangle {
                            Layout.fillWidth: true

                            height: 5
                            radius: 3

                            color: "#c1d9ca"

                            Rectangle {
                                height: parent.height
                                radius: 3

                                color: "#3c7e64"

                                width: parent.width * (
                                    taskManager.total
                                    ? taskManager.completed / taskManager.total
                                    : 0
                                )

                                Behavior on width {
                                    NumberAnimation {
                                        duration: 250
                                    }
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                spacing: 10

                ColumnLayout {
                    spacing: 5

                    Text {
                        text: "Daily agenda"
                        color: window.ink

                        font.pixelSize: 21
                        font.bold: true
                    }

                    Text {
                        text: taskManager.dateLabel
                        color: window.muted

                        font.pixelSize: 12
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                ActionButton {
                    text: "‹"

                    Accessible.name: "Previous day"

                    onClicked: taskManager.moveDay(-1)
                }

                ActionButton {
                    text: "Today"

                    onClicked: taskManager.today()
                }

                ActionButton {
                    text: "›"

                    Accessible.name: "Next day"

                    onClicked: taskManager.moveDay(1)
                }
            }

            RowLayout {
                Layout.fillWidth: true

                spacing: 7

                Repeater {
                    model: [
                        "All tasks",
                        "Pending",
                        "Completed"
                    ]

                    ActionButton {
                        required property int index
                        required property string modelData

                        text: modelData

                        primary: window.activeFilter === index

                        onClicked: {
                            window.activeFilter = index
                            taskManager.setFilter(index)
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Input {
                    id: search

                    Layout.preferredWidth: window.width < 900
                        ? 160
                        : 210

                    placeholderText: "Search this day…"

                    Accessible.name: "Search tasks for selected day"

                    onTextChanged: taskManager.setSearch(text)
                }
            }

            Rectangle {
                visible: taskManager.error !== ""
                    && !editor.visible

                Layout.fillWidth: true

                implicitHeight: errorText.implicitHeight + 24

                radius: 10
                color: "#fbe5e1"

                Text {
                    id: errorText

                    anchors.fill: parent
                    anchors.margins: 12

                    text: taskManager.error
                    wrapMode: Text.Wrap

                    color: "#983e3e"

                    font.pixelSize: 12
                }
            }

            ListView {
                id: taskList

                Layout.fillWidth: true
                Layout.fillHeight: true

                clip: true
                spacing: 11

                model: taskManager.tasks

                ScrollBar.vertical: ScrollBar {}

                delegate: Rectangle {
                    id: card

                    required property var modelData

                    width: taskList.width

                    height: modelData.notes ? 112 : 88

                    radius: 15
                    color: "#ffffff"

                    border.color: "#e4e9ee"

                    Rectangle {
                        x: 0
                        y: 20

                        width: 4
                        height: parent.height - 40

                        radius: 2

                        color: card.modelData.done
                            ? "#a3c6b3"
                            : [
                                "#86b6cc",
                                "#dfb65f",
                                "#e38d7d"
                              ][card.modelData.priority]
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 17

                        spacing: 12

                        CheckBox {
                            id: doneBox

                            indicator: Rectangle {
                                implicitWidth: 26
                                implicitHeight: 26

                                x: doneBox.leftPadding
                                y: (doneBox.height - height) / 2

                                radius: 8

                                color: doneBox.checked
                                    ? "#356c59"
                                    : "#ffffff"

                                border.color: doneBox.activeFocus
                                    ? "#42a58c"
                                    : doneBox.checked
                                      ? "#356c59"
                                      : "#c7d5ce"

                                Text {
                                    anchors.centerIn: parent

                                    text: "✓"
                                    color: "white"

                                    visible: doneBox.checked

                                    font.pixelSize: 17
                                }
                            }

                            checked: card.modelData.done

                            Accessible.name: "Mark "
                                + card.modelData.title
                                + " complete"

                            onClicked: taskManager.toggleTask(
                                card.modelData.id
                            )
                        }

                        ColumnLayout {
                            Layout.fillWidth: true

                            spacing: 7

                            Text {
                                Layout.fillWidth: true

                                text: card.modelData.title

                                elide: Text.ElideRight

                                color: card.modelData.done
                                    ? "#8d9a9e"
                                    : window.ink

                                font.pixelSize: 15
                                font.bold: true
                                font.strikeout: card.modelData.done
                            }

                            Text {
                                visible: card.modelData.notes !== ""

                                Layout.fillWidth: true

                                text: card.modelData.notes.replace(
                                    /\n/g,
                                    " · "
                                )

                                elide: Text.ElideRight

                                color: window.muted

                                font.pixelSize: 12
                            }

                            RowLayout {
                                spacing: 10

                                Text {
                                    text: card.modelData.time || "Anytime"

                                    color: "#7b8791"

                                    font.pixelSize: 11
                                }

                                Text {
                                    text: "•"
                                    color: "#bac3cb"
                                }

                                Text {
                                    text: [
                                        "Low priority",
                                        "Medium priority",
                                        "High priority"
                                    ][card.modelData.priority]

                                    color: [
                                        "#558498",
                                        "#99742e",
                                        "#b76856"
                                    ][card.modelData.priority]

                                    font.pixelSize: 11
                                }
                            }
                        }

                        ActionButton {
                            text: "Edit"

                            onClicked: window.openEditor(
                                card.modelData
                            )
                        }

                        ActionButton {
                            text: "×"

                            destructive: true

                            Accessible.name: "Delete "
                                + card.modelData.title

                            onClicked: {
                                window.deletingId = card.modelData.id
                                deleteDialog.open()
                            }
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent

                    visible: taskList.count === 0

                    spacing: 15

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: "☀"
                        color: "#b1cbbd"

                        font.pixelSize: 48
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: taskManager.total === 0
                            ? "Space for something good."
                            : "No matching tasks."

                        color: window.ink

                        font.pixelSize: 20
                        font.bold: true
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: taskManager.total === 0
                            ? "Add your first task for this day."
                            : "Try another filter or search."

                        color: window.muted

                        font.pixelSize: 12
                    }

                    ActionButton {
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: "+  Add a task"

                        primary: true

                        onClicked: window.openEditor(null)
                    }
                }
            }

            Text {
                Layout.fillWidth: true

                text: "Local JSON storage  ·  Ctrl+N new task  ·  Ctrl+F search"

                color: window.muted

                font.pixelSize: 10
            }
        }
    }

    Dialog {
        id: editor

        anchors.centerIn: parent

        width: Math.min(window.width - 48, 530)
        height: Math.min(window.height - 32, 690)

        modal: true
        padding: 24

        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: 20
            color: "white"
        }

        contentItem: ScrollView {
            clip: true

            ColumnLayout {
                width: editor.availableWidth

                spacing: 12

                Text {
                    text: window.editingId
                        ? "Edit your task"
                        : "Make a little plan."

                    font.pixelSize: 25
                    font.bold: true

                    color: window.ink
                }

                Text {
                    text: "Give your day a clear next step."

                    color: window.muted
                }

                Label {
                    text: "Task title"

                    color: window.ink
                }

                Input {
                    id: titleInput

                    Layout.fillWidth: true

                    placeholderText: "What would you like to do?"

                    maximumLength: 120

                    Accessible.name: "Task title"
                }

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true

                        Label {
                            text: "Date · YYYY-MM-DD"

                            color: window.ink
                        }

                        Input {
                            id: dateInput

                            Layout.fillWidth: true

                            placeholderText: "2026-11-16"

                            Accessible.name: "Task date"
                        }
                    }

                    ColumnLayout {
                        Layout.preferredWidth: 150

                        Label {
                            text: "Time · optional"

                            color: window.ink
                        }

                        Input {
                            id: timeInput

                            Layout.fillWidth: true

                            placeholderText: "09:30"

                            Accessible.name: "Task time in HH:mm format"
                        }
                    }
                }

                Label {
                    text: "Priority"

                    color: window.ink
                }

                ComboBox {
                    id: priorityInput

                    Layout.fillWidth: true

                    model: [
                        "Low — whenever you can",
                        "Medium — keep it moving",
                        "High — make it a focus"
                    ]

                    Accessible.name: "Task priority"
                }

                Label {
                    text: "Notes · optional"

                    color: window.ink
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 105

                    TextArea {
                        id: notesInput

                        placeholderText: "A few details to help you get started…"

                        wrapMode: TextEdit.Wrap
                        selectByMouse: true

                        padding: 12

                        Accessible.name: "Task notes"

                        background: Rectangle {
                            radius: 10
                            color: "#f4f6f8"

                            border.color: "#dce3e8"
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true

                    visible: taskManager.error !== ""

                    text: taskManager.error

                    color: "#b94b4b"

                    wrapMode: Text.Wrap

                    font.pixelSize: 12
                }

                RowLayout {
                    Layout.topMargin: 8
                    Layout.fillWidth: true

                    ActionButton {
                        text: "Cancel"

                        onClicked: editor.close()
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    ActionButton {
                        text: "Save task"

                        primary: true

                        onClicked: {
                            const saved = taskManager.saveTask(
                                window.editingId,
                                titleInput.text,
                                notesInput.text,
                                dateInput.text,
                                timeInput.text,
                                priorityInput.currentIndex
                            )

                            if (saved) {
                                editor.close()
                            }
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: deleteDialog

        anchors.centerIn: parent

        width: 390
        modal: true

        title: "Delete this task?"

        standardButtons: Dialog.Cancel | Dialog.Yes

        Label {
            width: parent.width

            text: "This will permanently remove the task."

            wrapMode: Text.Wrap
        }

        onAccepted: taskManager.removeTask(
            window.deletingId
        )
    }
}