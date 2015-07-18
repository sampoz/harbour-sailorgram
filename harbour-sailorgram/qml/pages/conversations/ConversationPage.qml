import QtQuick 2.1
import Sailfish.Silica 1.0
import harbour.sailorgram.TelegramQml 1.0
import "../../models"
import "../../menus/conversation"
import "../../components"
import "../../items/peer"
import "../../items/user"
import "../../items/messageitem"
import "../../js/TelegramHelper.js" as TelegramHelper

Page
{
    property Context context
    property Dialog dialog
    property Chat chat
    property User user
    property bool muted: context.telegram.userData.isMuted(TelegramHelper.peerId(dialog))

    id: conversationpage
    allowedOrientations: defaultAllowedOrientations

    Component.onCompleted: {
        if(TelegramHelper.isChat(dialog))
            chat = context.telegram.chat(dialog.peer.chatId);
        else
            user = context.telegram.user(dialog.peer.userId);
    }

    onStatusChanged: {
        if(status !== PageStatus.Active)
            return;

        pageStack.pushAttached(Qt.resolvedUrl("ConversationInfoPage.qml"), { "context": conversationpage.context, "dialog": conversationpage.dialog, "chat": conversationpage.chat, "user": conversationpage.user });
        context.foregroundDialog = conversationpage.dialog;

        messagemodel.setReaded();
        messagemodel.telegram = conversationpage.context.telegram;
        messagemodel.dialog = conversationpage.dialog;
    }

    RemorsePopup { id: remorsepopup }

    Timer
    {
        id: refreshtimer
        repeat: true
        interval: 10000
        onTriggered: messagemodel.refresh()
        Component.onCompleted: start()
    }

    PopupMessage
    {
        id: popupmessage
        anchors { left: parent.left; top: parent.top; right: parent.right }
    }

    Connections
    {
        target: context.telegram.userData

        onMuteChanged: {
            var peerid = TelegramHelper.peerId(dialog);

            if(id !== peerid)
                return;

            conversationpage.muted = context.telegram.userData.isMuted(peerid);
        }
    }

    SilicaFlickable
    {
        id: flickable
        anchors.fill: parent

        ConversationMenu
        {
            id: conversationmenu
            context: conversationpage.context
            dialog: conversationpage.dialog
        }

        PeerItem
        {
            id: header
            anchors { left: parent.left; top: parent.top; right: parent.right; leftMargin: Theme.horizontalPageMargin; topMargin: Theme.paddingMedium }
            height: Theme.itemSizeSmall
            context: conversationpage.context
            dialog: conversationpage.dialog
            chat: conversationpage.chat
            user: conversationpage.user
        }

        SilicaListView
        {
            id: lvconversation
            anchors { left: parent.left; top: header.bottom; right: parent.right; bottom: messagebar.top; topMargin: Theme.paddingSmall }
            verticalLayoutDirection: ListView.BottomToTop
            spacing: Theme.paddingLarge
            clip: true

            TelegramBackground { id: telegrambackground; z: -1 }

            BusyIndicator {
                anchors.centerIn: parent
                size: BusyIndicatorSize.Large
                running: messagemodel.refreshing
            }

            model: MessagesModel {
                id: messagemodel

                onCountChanged: {
                    if(!count)
                        return;

                    messagemodel.setReaded(); /* We are in this chat, always mark these messages as read */
                }
            }

            delegate: MessageItem {
                context: conversationpage.context
                message: item
            }
        }

        MessageBar
        {
            id: messagebar
            anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
            context: conversationpage.context
            dialog: conversationpage.dialog
        }
    }
}
