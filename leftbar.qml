import QtQuick 2.7
import QtQuick.Controls 2.1

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")


    function startParse(url) {
        //url = 'file:///' + pathGetter.getCurrentPath() + '/' + url
        var http = new XMLHttpRequest()
        http.onreadystatechange = function() {
            if (http.readyState === XMLHttpRequest.DONE) {
                var json = JSON.parse(http.responseText)
                var data = json['data']
                for (var i = 0; i < data.length; ++i) {
                    var lists = data[i]['lists']
                    var arr = []
                    for (var j = 0; j < lists.length; ++j)
                        arr.push({ 'icon': lists[j].icon, 'name': lists[j].name, 'url': lists[j].url })
                    listmodel.append({ 'section': data[i].section, 'canCollapse': data[i].canCollapse, 'lists': arr })
                    //                        listmodel.append( { 'section': data[i].section, 'canCollapse': data[i].canCollapse, 'name': lists[j].name })
                }
            }
        }

        http.open('GET', url, true)
        http.send()
    }
    Component {
        id: itemdelegate
        Item {
            id: wrapper
            width: listview.width
            height: row.height + column.height
            MouseArea {
                anchors.fill: parent
                onClicked: listview.currentIndex = index
            }

            Item {
                id: sectionItem
                width: parent.width
                height: 30
                Row {
                    id: row
                    anchors.fill: parent
                    padding: 6
                    Text {
                        text: section
                        //                        verticalAlignment: Text.AlignVCenter
                        anchors.verticalCenter: parent.verticalCenter
                        color: '#7d7d7d'
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    //                    propagateComposedEvents: true
                    cursorShape: canCollapse ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        //                        mouse.accepted = false
                        if (canCollapse) {
                            if (column.height === 0)
                                column.height = repater.count * 30
                            else
                                column.height = 0
                            column.visible = !column.visible
                        }
                    }
                }
            }

            Column {
                id: column
                width: listview.width
                anchors.top: sectionItem.bottom
                anchors.topMargin: 6
                property int currentIndex: listview.currentIndex
                Repeater {
                    id: repater
                    model: lists
                    delegate: Item {
                        width: listview.width
                        height: 30
                        Rectangle {
                            visible: column.currentIndex === index && wrapper.ListView.isCurrentItem
                            anchors.fill: parent
                            color: '#e6e7ea'
                            Rectangle {
                                width: 4
                                height: parent.height
                                color: '#c62f2f'
                            }
                        }

                        Text {
                            id: iconText
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            font.family: 'icomoon'
                            text: icon
                            font.pointSize: 11
                            font.bold: false
                            anchors.verticalCenter: parent.verticalCenter
                            color: '#5c5c5c'
                        }

                        Text {
                            id: nameText
                            anchors.leftMargin: 10
                            anchors.left: iconText.right
                            text: name
                            anchors.verticalCenter: parent.verticalCenter
                            color: iconText.color
                        }
                        MouseArea {
                            anchors.fill: parent
                            propagateComposedEvents: true
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.currentPage(url)
                                column.currentIndex = index
                                mouse.accepted = false
                            }
                            onEntered: iconText.color = 'black'
                            onExited: iconText.color = '#5c5c5c'
                        } /////// mousearea

                    }
                }
            }
        }
    }
    Component {
    	id: component
    	Item {
            id: wrapper
            width: listview.width
            height: rootItem.height + column.height

            Rectangle {
                id: rootItem
                width: parent.width
                height: 30
                color: 'red'
                Text { text: section }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        wrapper.state = (wrapper.state == "" ? "collapse" : "")
                    }
                    hoverEnabled: true
                    onEntered: rootItem.color = Qt.lighter('red', 1.2)
                    onPressed: rootItem.color = Qt.darker('red', 1.2)
                    onExited: rootItem.color = 'red'
                }
            }

            Column {
                id: column
                anchors.top: rootItem.bottom
                width: parent.width
                height: repeater.height
                Repeater {
                    id: repeater
                    width: parent.width
                    height: 20 * count
                    model: lists

                    delegate: Rectangle {
                        id: itemRect
                        width: listview.width
                        height: 20
                        color: 'blue'
                        Text { text: name; anchors.centerIn: parent }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                wrapper.state = (wrapper.state == "" ? "collapse" : "")
                            }
                            hoverEnabled: true
                            onEntered: itemRect.color = Qt.lighter('blue', 1.2)
                            onPressed: itemRect.color = Qt.darker('blue', 1.2)
                            onExited: itemRect.color = 'blue'
                        }
                    }
                }
            }

            state: ""

            states: [
                State {
                    name: "collapse"
                    PropertyChanges {
                        target: column
                        height: 0
                        visible: false
                    }
                },

                State {
                    name: ""
                    PropertyChanges {
                        target: column
                        height: repeater.height
                        visible: true
                    }
                }

            ]
        }
    }

    ListView {
        id: listview

        anchors.fill: parent
        model: listmodel

        delegate: component
        // delegate: itemdelegate
    }


    ListModel {
        id: listmodel
    }

    function readFile() {
        var http = new XMLHttpRequest;
        http.onreadystatechange = function() {
            if (http.readyState == XMLHttpRequest.DONE) {
                var jsonStr = http.responseText
                var json = JSON.parse(jsonStr)
                parseJson(json)
            }
        }

        http.open("GET", "data.json")
        http.send()
    }

    function parseJson(json) {
        json = json.allStations
        for (var i = 0;i < json.length; ++i) {
            var stationName = json[i].stationName

            var lists = json[i].stations
            var stations = []
            console.log(lists.length)

            for (var j = 0; j < lists.length; ++j) {
                console.log(lists[i])
                stations.push({"name": lists[j].name })
            }

            listmodel.append({
                              "stationName": stationName,
                              "stations": stations
                             })
        }
    }

    Component.onCompleted: {
        // readFile()
        startParse('left.json')
    }

}
