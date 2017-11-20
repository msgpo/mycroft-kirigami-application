import QtQuick 2.9
import QtQml.Models 2.3
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.WebSockets 1.0
import org.kde.kirigami 2.1 as Kirigami

Kirigami.ScrollablePage {
   id: pageRoot

   background: Rectangle {
           color: Kirigami.Theme.backgroundColor
   }
   title: "Home"
   property alias mainpage: pageRoot
   property var smintent
   property var dataContent
   property alias cbwidth: pageRoot.width

   function testDbus(getState){
       convoLmodel.append({
           "itemType": "NonVisual",
           "InputQuery": getState
       })
   }

   function playwaitanim(recoginit){
       switch(recoginit){
       case "recognizer_loop:record_begin":
               drawer.open()
               waitanimoutter.cstanim.running = true
               break
           case "recognizer_loop:audio_output_start":
               drawer.close()
               waitanimoutter.cstanim.running = false
               break
           case "mycroft.skill.handler.complete":
               drawer.close()
               waitanimoutter.cstanim.running = false
               break
       }
   }

   function filterSpeak(msg){
              convoLmodel.append({
                  "itemType": "NonVisual",
                  "InputQuery": msg
              })
                 inputlistView.positionViewAtEnd();
          }

          function filterincoming(intent, metadata) {
              var intentVisualArray = ['CurrentWeatherIntent'];
                      var itemType
                      var filterintentname = intent.split(':');
                      var intentname = filterintentname[1];

              if (intentVisualArray.indexOf(intentname) !== -1) {
                      switch (intentname){
                      case "CurrentWeatherIntent":
                          itemType = "CurrentWeather"
                          break;
                      }

                    convoLmodel.append({"itemType": itemType, "itemData": metadata})
                      }

              else {
                  convoLmodel.append({"itemType": "WebViewType", "InputQuery": metadata.url})
              }
          }

          function clearList() {
                  inputlistView.clear()
  }

          WebSocket {
                  id: socket
                  url: "ws://0.0.0.0:8181/core"
                  onTextMessageReceived: {
                      var somestring = JSON.parse(message)
                                  console.log(message)
                                  //filterdbg(message)
                                  var msgType = somestring.type;
                                   playwaitanim(msgType);
                                  //qinput.focus = false;

                                  if (msgType === "recognizer_loop:utterance") {
                                      var intpost = somestring.data.utterances;
                                      //qinput.text = intpost.toString()
                                      //midbarAnim.wsistalking()
                                  }

                                  if (somestring && somestring.data && typeof somestring.data.intent_type !== 'undefined'){
                                      smintent = somestring.data.intent_type;
                                      console.log('intent type: ' + smintent);
                                  }

                                  if(somestring && somestring.data && typeof somestring.data.utterance !== 'undefined' && somestring.type === 'speak'){
                                      filterSpeak(somestring.data.utterance);
                                  }

                                  if(somestring && somestring.data && typeof somestring.data.desktop !== 'undefined') {
                                      dataContent = somestring.data.desktop
                                      filterincoming(smintent, dataContent)
                                  }

                                  //midbarAnim.wsistalking()
                  }

                  onStatusChanged: if (socket.status == WebSocket.Error) {
                                           //connectws.text = "Error"
                                           //connectws.color = "red"
                                           //startmycservice.circolour = "red"
                                    } else if (socket.status == WebSocket.Open) {
                                           //connectws.text = "Ready"
                                           //connectws.color = "green"
                                           //startmycservice.circolour = "green"
                                    } else if (socket.status == WebSocket.Closed) {
                                           //connectws.text = "Closed"
                                           //connectws.color = "white"
                                    } else if (socket.status == WebSocket.Connecting) {
                                           //connectws.text = "Starting.."
                                           //connectws.color = "white"
                                    } else if (socket.status == WebSocket.Closing) {
                                           //connectws.text = "Shutting.."
                                           //connectws.color = "blue"
                                           //startmycservice.circolour = "#1e4e62"
                                    }


                  active: true
          }

          ListModel{
          id: convoLmodel
          }

            ListView {
                id: inputlistView
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                verticalLayoutDirection: ListView.TopToBottom
                spacing: 12
                clip: true
                model: convoLmodel
                delegate:  Component {
                           Loader {
                               source: switch(itemType) {
                                       case "NonVisual": return "SimpleMessageType.qml"
                                       case "WebViewType": return "WebViewType.qml"
                                       case "CurrentWeather": return "CurrentWeatherType.qml"
                                       case "DropImg" : return "ImgRecogType.qml"
                                       }
                                property var metacontent : dataContent
                               }
                       }

            onCountChanged: {
                inputlistView.positionViewAtEnd();
                           }
                                             }

            footer:
                Rectangle{
                id: bottombar
                anchors.left: parent.left
                anchors.right: parent.right
                height:60
                color: Kirigami.Theme.backgroundColor

                Image {
                    id: waitanimoutter
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    opacity: 0
                    height: 60
                    width: 60

                Drawer {
                    id: drawer
                    width: parent.width
                    height: 0.22 * pageRoot.height
                    edge: Qt.BottomEdge

                    background: Rectangle {
                            color: Kirigami.Theme.backgroundColor
                    }

                    CustomIndicator {
                        id: waitanimoutter
                        anchors.centerIn: parent
                        height: 80
                        width: 80
                    }
                }
    

                TextField {
                    id: qinput
                    //height: 60
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 90
                    anchors.right: parent.right
                    anchors.rightMargin: 90
                    placeholderText: qsTr("Enter Query or Say 'Hey Mycroft'")
                    onAccepted: {
                        var socketmessage = {};
                        socketmessage.type = "recognizer_loop:utterance";
                        socketmessage.data = {};
                        socketmessage.data.utterances = [qinput.text];
                        socket.sendTextMessage(JSON.stringify(socketmessage));
                        convoLmodel.append({
                            "itemType": "NonVisual",
                            "InputQuery": qinput.text
                        })
                           inputlistView.positionViewAtEnd();

                                             }
                                                 }
                                                   }
}
