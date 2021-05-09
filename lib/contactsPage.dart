import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:contacts_app/smsButton.dart';
import 'package:contacts_app/phoneButton.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  Iterable<Contact> _contacts;
  List<Contact> _contactList = [];

  @override
  void initState() {
    getContacts();
    super.initState();
  }

  Future<void> contactPermission() async {
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus != PermissionStatus.granted) {
      //If permissions have been denied show standard cupertino alert dialog
      showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: Text('Permissions error'),
            content: Text('Please enable contacts access '
                'permission in system settings'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ));
    }
  }

  Future<void> getContacts() async {
    await contactPermission();
    //We already have permissions for contact when we get to this page, so we
    // are now just retrieving it
    Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  @override
  Widget build(BuildContext context) {

    if(_contacts != null) {
      _contacts.forEach((element) {
        if(element.phones != null){
          _contactList.add(element);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: (Text('Contacts')),
      ),
      body: _contactList != null
      //Build a list view of all contacts, displaying their avatar and
      // display name
          ? ListView.builder(
        itemCount: _contactList?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          Contact contact = _contactList?.elementAt(index);
          return ListTile(
            contentPadding:
            const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
            leading: (contact.avatar != null && contact.avatar.isNotEmpty)
                ? CircleAvatar(
              backgroundImage: MemoryImage(contact.avatar),
            )
                : CircleAvatar(
              child: Text(contact.initials()),
              backgroundColor: Theme.of(context).accentColor,
            ),
            title: Text(contact.displayName ?? ''),
            //This can be further expanded to showing contacts detail
            // onPressed().
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                PhoneButton(phoneNumbers: contact.phones),
                SmsButton(phoneNumbers: contact.phones)
              ],
            ),
          );
        },
      )
          : Center(child: const CircularProgressIndicator()),
    );
  }
}

Future<PermissionStatus> _getPermission() async {
  final PermissionStatus permission = await Permission.contacts.status;
  if (permission != PermissionStatus.granted &&
      permission != PermissionStatus.denied) {
    final Map<Permission, PermissionStatus> permissionStatus =
    await [Permission.contacts].request();
    return permissionStatus[Permission.contacts] ??
        PermissionStatus.undetermined;
  } else {
    return permission;
  }
}