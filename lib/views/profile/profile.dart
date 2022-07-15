import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:splitpay/models/user.dart';
import 'package:splitpay/views/profile/add_friend.dart';
import 'package:splitpay/views/profile/add_group.dart';
import 'package:splitpay/views/profile/sign_out.dart';

class Profile extends StatefulWidget {
  const Profile({ Key? key }) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserId>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Theme.of(context).backgroundColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: CircleAvatar(
                radius: 50.0,
                backgroundImage: NetworkImage(user.photoURL!),
              ),
            ),
          ),
          Divider(),
          InkWell(
            onTap: (){
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return AddFriend(uid: user.uid);
                },
              );
            },
            child: ListTile(
              title: Text('Add Friend'),
              trailing: Icon(
                Icons.person_add,
                color: Colors.blueGrey,
              ),
            ),
          ),
          Divider(),
          InkWell(
            onTap: (){
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return AddGroup(uid: user.uid);
                },
              );
            },
            child: ListTile(
              title: Text('Add Group'),
              trailing: Icon(
                Icons.group_add,
                size: 30,
                color: Colors.blueGrey,
              ),
            ),
          ),
          Divider(),
          InkWell(
            child: ListTile(
                title: Text('Sign Out'),
                trailing: Icon(
                  Icons.logout,
                  color: Colors.blueGrey,
                ),
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0))),
                      builder: (context) {
                        return SignOut();
                      });
                }),
          ),
        ],
      ),
    );
  }
}