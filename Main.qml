/***************************************************************************
* Copyright (c) 2015 Víctor Granda García <victorgrandagarcia@gmail.com>
* Copyright (c) 2015 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
* Copyright (c) 2013 Abdurrahman AVCI <abdurrahmanavci@gmail.com>
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without restriction,
* including without limitation the rights to use, copy, modify, merge,
* publish, distribute, sublicense, and/or sell copies of the Software,
* and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
* OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
* OR OTHER DEALINGS IN THE SOFTWARE.
*
***************************************************************************/

import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
  id: container
  width: 1024
  height: 768

  LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
  LayoutMirroring.childrenInherit: true

  property int sessionIndex: session.index

  TextConstants {
    id: textConstants
  }

  Connections {
    target: sddm
    onLoginSucceeded: {
    }

    onLoginFailed: {
      errorMessage.color = "#dc322f"
      errorMessage.text = textConstants.loginFailed
    }
  }

  FontLoader {
    id: textFont; name: config.displayFont
  }

  Repeater {
    model: screenModel
    Background {
      x: geometry.x; y: geometry.y; width: geometry.width; height:geometry.height
      source: config.background
      fillMode: Image.PreserveAspectCrop
      onStatusChanged: {
        if (status == Image.Error && source != config.defaultBackground) {
          source = config.defaultBackground
        }
      }
    }
  }

  Rectangle {
    anchors.fill: parent
    color: "transparent"
    // numix theme properties
    //property variant geometry: screenModel.geometry(screenModel.primary)
    //x: geometry.x; y: geometry.y; width: geometry.width; height: geometry.height
    // primary screen
    //visible: primaryScreen

    Rectangle {
      id: clockContainer
      width: parent.width / 3
      height: parent.height * 0.3
      color: "transparent"
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.rightMargin: 20

      Clock {
        id: clock
        //anchors.centerIn: parent
        color: "#839496"
        timeFont.family: textFont.name
        dateFont.family: textFont.name
      }
    }

    Rectangle {
      width: parent.width / 3
      height: parent.height * 0.3
      color: "transparent"
      anchors.top: clockContainer.bottom
      anchors.right: parent.right
      //anchors.rightMargin: 20
      clip: true

      Item {
        id: usersContainer
        width: parent.width; height: parent.height
        //anchors.verticalCenter: parent.verticalCenter

        Column {
          id: nameColumn
          width: parent.width * 0.4
          spacing: 10
          anchors.margins: 10

          Text {
            id: lblName
            width: parent.width
            text: textConstants.userName
            font.family: textFont.name
            font.bold: true
            font.pixelSize: 16
            color: "#839496"
          }

          TextBox {
            id: name
            width: parent.width
            text: userModel.lastUser
            font: textFont.name
            //font.pixelSize: 16
            color: "#25000000"
            borderColor: "transparent"
            textColor: "#839496"

            Keys.onPressed: {
              if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                sddm.login(name.text, password.text, session.index)
                event.accepted = true
              }
            }

            KeyNavigation.backtab: layoutBox; KeyNavigation.tab: password
          }
          Text {
            id: errorMessage
            //anchors.horizontalCenter: parent.horizontalCenter
            anchors.left: name.left
            text: textConstants.prompt
            font.family: textFont.name
            font.pixelSize: 12
            color: "#839496"
          }
        }

        Column {
          id: passColumn
          width: parent.width * 0.4
          spacing: 10
          anchors.margins: 10
          anchors.left: nameColumn.right

          Text {
            id: lblPassword
            width: parent.width
            text: textConstants.password
            font.family: textFont.name
            font.bold: true
            font.pixelSize: 16
            color: "#839496"
          }

          PasswordBox {
            id: password
            //focus: true
            width: parent.width
            font: textFont.name
            //font.pixelSize: 16
            color: "#25000000"
            borderColor: "transparent"
            textColor: "#839496"
            tooltipBG: "#25000000"
            tooltipFG: "#dc322f"
            image: "warning_red.png"

            Keys.onPressed: {
              if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                sddm.login(name.text, password.text, session.index)
                event.accepted = true
              }
            }

            KeyNavigation.backtab: name; KeyNavigation.tab: loginButton
          }

          Button {
            id: loginButton
            text: textConstants.login
            width: parent.width * 0.4
            anchors.right: password.right
            color: "#268bd2"
            disabledColor: "#dc322f"
            activeColor: "#268bd2"
            pressedColor: "#2aa198"
            textColor: "black"
            font: textFont.name

            onClicked: sddm.login(name.text, password.text, session.index)

            KeyNavigation.backtab: password; KeyNavigation.tab: btnReboot
          }
        }
      }
    }
  }
  Rectangle {
    id: actionBar
    anchors.top: parent.top;
    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width; height: 40
    color: "transparent"
    // primary screen
    //visible: primaryScreen

    Row {
      anchors.left: parent.left
      anchors.margins: 5
      height: parent.height
      spacing: 10

      Text {
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter

        //text: textConstants.session
        text: "Window Manager"
        font.family: textFont.name
        font.pixelSize: 16
        font.bold: true
        verticalAlignment: Text.AlignVCenter
        color: "#b58900"
      }

      ComboBox {
        id: session
        width: 245
        height: 20
        anchors.verticalCenter: parent.verticalCenter
        color: "#25000000"
        textColor: "#b58900"
        borderColor: "transparent"
        hoverColor: "#073642"
        arrowIcon: "angle-down.svg"
        arrowColor: "#25000000"

        model: sessionModel
        index: sessionModel.lastIndex
        font.family: textFont.name
        font.pixelSize: 14
        //dropDown.color: "transparent"

        KeyNavigation.backtab: btnShutdown; KeyNavigation.tab: layoutBox
      }

      Text {
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter

        //text: textConstants.layout
        text: "Keyboard Layout"
        font.family: textFont.name
        font.pixelSize: 16
        font.bold: true
        verticalAlignment: Text.AlignVCenter
        color: "#b58900"
      }

      //LayoutBox {
      //    id: layoutBox
      //    width: 90
      //    height: 20
      //    anchors.verticalCenter: parent.verticalCenter
      //    font.family: textFont.name
      //    font.pixelSize: 14
      //    color: "#25000000"
      //    textColor: "#b58900"
      //    borderColor: "transparent"

      //    arrowIcon: "angle-down.svg"

      //    KeyNavigation.backtab: session; KeyNavigation.tab: btnShutdown
      //}
      ComboBox {
        id: layoutBox

        model: keyboard.layouts
        index: keyboard.currentLayout
        width: 50
        height: 20
        anchors.verticalCenter: parent.verticalCenter
        color: "#25000000"
        textColor: "#b58900"
        borderColor: "transparent"
        hoverColor: "#073642"
        arrowIcon: "angle-down.svg"
        arrowColor: "#25000000"

        onValueChanged: keyboard.currentLayout = id

        Connections {
          target: keyboard

          onCurrentLayoutChanged: combo.index = keyboard.currentLayout
        }

        rowDelegate: Rectangle {
          color: "transparent"

          Text {
            anchors.margins: 4
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            verticalAlignment: Text.AlignVCenter

            text: modelItem ? modelItem.modelData.shortName : "zz"
            font.family: textFont.name
            font.pixelSize: 14
            color: "#b58900"
          }
        }
        KeyNavigation.backtab: session; KeyNavigation.tab: name
      }
    }

    Row {
      height: parent.height
      anchors.right: parent.right
      //anchors.left: actionBar.right
      anchors.margins: 5
      spacing: 10

      ImageButton {
        id: btnReboot
        height: parent.height
        source: "reboot.svg"

        visible: sddm.canReboot

        onClicked: sddm.reboot()

        KeyNavigation.backtab: loginButton; KeyNavigation.tab: btnShutdown
      }

      ImageButton {
        id: btnShutdown
        height: parent.height
        source: "shutdown.svg"

        visible: sddm.canPowerOff

        onClicked: sddm.powerOff()

        KeyNavigation.backtab: btnReboot; KeyNavigation.tab: session
      }
    }
  }

  Component.onCompleted: {
        if (name.text == "")
            name.focus = true
        else
            password.focus = true
    }
}
