import QtQuick 2.1
import Sailfish.Silica 1.0
import harbour.sailorgram.TelegramQml 2.0 as Telegram
import "../../models"
import "../../items/user"
import "../../js/TelegramHelper.js" as TelegramHelper

Page
{
    property Context context

    id: createsecretdialogpage
    allowedOrientations: defaultAllowedOrientations

    SilicaFlickable
    {
        anchors.fill: parent

        PageHeader
        {
            id: pageheader
            title: qsTr("New Secret Chat")
        }

        SilicaListView
        {
            id: lvcontacts
            anchors { left: parent.left; top: pageheader.bottom; right: parent.right; bottom: parent.bottom }
            spacing: Theme.paddingMedium
            clip: true

            model: Telegram.DialogListModel {
                id: contactsmodels
                engine: context.engine
                visibility: Telegram.DialogListModel.VisibilityContacts | Telegram.DialogListModel.VisibilityEmptyDialogs
                sortFlag: [ Telegram.DialogListModel.SortByName, Telegram.DialogListModel.SortByOnline ]
            }

            delegate: ListItem {
                contentWidth: parent.width
                contentHeight: Theme.itemSizeSmall

                onClicked: {
                    context.telegram.messagesCreateEncryptedChat(item.userId);
                    pageStack.pop();
                }

                UserItem {
                    id: useritem
                    anchors { fill: parent; leftMargin: Theme.paddingMedium; rightMargin: Theme.paddingMedium }
                    context: createsecretdialogpage.context
                    user: model.user
                }
            }
        }
    }
}
