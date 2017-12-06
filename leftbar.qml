import QtQuick 2.7
import QtQuick.Controls 2.1

Rectangle {
    id: root
    color: '#f5f5f7'
    //    // 右分割线
    //    Line {
    //        anchors.right: parent.right
    //        width: 2
    //        height: parent.height
    //    }

    signal currentPage(string page)
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


    function updateCurrentIndex(index) {
        if (index !== -1 && index < listview.count)
            listview.currentIndex = index
    }

    ListModel {
        id: listmodel
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

    ListView {
        id: listview
        width: parent.width
        height: parent.height - musicInfo.height
        boundsBehavior: ListView.StopAtBounds

        signal clickSection(string section)
        model: listmodel
        spacing: 10
        clip: true

        //        section.property: 'section'
        //        section.delegate: sectionDelegate
        //        delegate: listviewDelegate

        delegate: itemdelegate
        ScrollBar.vertical: ScrollBar { width: 10; active: true}

    }

    
    Component.onCompleted: startParse('left.json')
}