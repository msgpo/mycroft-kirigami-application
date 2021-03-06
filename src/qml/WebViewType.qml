import QtQuick 2.9
import QtQml.Models 2.3
import QtQuick.Controls 2.2
import QtWebKit 3.0
import QtWebKit.experimental 1.0
import org.kde.kirigami 2.1 as Kirigami

Column {
                    spacing: 6
                    anchors.right: parent.right
                        
                    Row {
                        id: messageRow
                        spacing: 6
                            
                    Rectangle {
                        id: messageRect
                        width: cbwidth
                        radius: 2
                        height: newwvFlick.height
                        color: Qt.lighter(Kirigami.Theme.backgroundColor, 1.2)

                        Flickable {
                            id: newwvFlick
                            width: messageRect.width
                            height: wview.experimental.page.height

                            WebView {
                                id: wview
                                anchors.fill: parent
                                url: "file:///" + model.InputQuery
                                experimental.userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"

                                onLoadingChanged: {
                                console.log(wview.url)
                                }
                                    }
                                        }
                                            }
                                                }
                                                    }
