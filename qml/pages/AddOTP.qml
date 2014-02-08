/*
 * Copyright (c) 2013, Stefan Brand <seiichiro@seiichiro0185.org>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this 
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this
 *    list of conditions and the following disclaimer in the documentation and/or other 
 *    materials provided with the distribution.
 * 
 * 3. The names of the contributors may not be used to endorse or promote products 
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE 
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/storage.js" as DB // Import the storage library for Config-Access

// Define Layout of the Add OTP Dialog
Dialog {
  id: addOTP

	// We get the Object of the parent page on call to refresh it after adding a new Entry
  property QtObject parentPage: null

  // If we want to edit a Key we get title and key from the calling page
  property string paramType: "TOTP"
  property string paramLabel: ""
  property string paramKey: ""
  property int paramCounter: 1 // New Counters start at 1

  SilicaFlickable {
    id: addOtpList
    anchors.fill: parent

    VerticalScrollDecorator {}

    Column {
      anchors.fill: parent
      DialogHeader {
        acceptText: paramLabel != "" ? qsTr("Save") : qsTr("Add")
      }

      ComboBox {
        id: typeSel
        label: qsTr("Type")
        menu: ContextMenu {
          MenuItem { text: qsTr("Time-based (TOTP)"); onClicked: { paramType = "TOTP" } }
          MenuItem { text: qsTr("Counter-based (HOTP)"); onClicked: { paramType = "HOTP" } }
        }
      }
      TextField {
        id: otpLabel
        width: parent.width
        label: qsTr("Title")
        placeholderText: qsTr("Title for the OTP")
        text: paramLabel != "" ? paramLabel : ""
        focus: true
        horizontalAlignment: TextInput.AlignLeft
      }
      TextField {
        id: otpSecret
        width: parent.width
        label: qsTr("Secret (at least 16 characters)")
        text: paramKey != "" ? paramKey : ""
        placeholderText: qsTr("Secret OTP Key")
        focus: true
        horizontalAlignment: TextInput.AlignLeft
      }
      TextField {
        id: otpCounter
        width: parent.width
        visible: paramType == "HOTP" ? true : false
        label: qsTr("Next Counter Value")
        text: paramCounter
        placeholderText: qsTr("Next Value of the Counter")
        focus: true
        horizontalAlignment: TextInput.AlignLeft
        validator: IntValidator { bottom: 0 }
      }
      Component.onCompleted: { typeSel.currentIndex = paramType == "HOTP" ? 1 : 0 }
    }
  }

  // Check if we can Save
  canAccept: otpLabel.text.length > 0 && otpSecret.text.length >= 16 && (paramType == "TOTP" || otpCounter.text.length > 0) ? true : false

  // Save if page is Left with Add
  onDone: {
    if (result == DialogResult.Accepted) {
			// Save the entry to the Config DB
      if (paramLabel != "" && paramKey != "") {
        // Parameters where filled -> Change existing entry
        DB.changeOTP(otpLabel.text, otpSecret.text, paramType, otpCounter.text, paramLabel, paramKey)
      } else {
        // There were no parameters -> Add new entry
        DB.addOTP(otpLabel.text, otpSecret.text, paramType, otpCounter.text);
      }
			// Refresh the main Page
      parentPage.refreshOTPList();
    }
  }
}




