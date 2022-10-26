import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:splitpay/config.dart';
import 'package:splitpay/models/user.dart';
import 'package:splitpay/views/components/loading.dart';
import 'package:splitpay/views/profile/add_friend.dart';
import 'package:splitpay/views/profile/add_group.dart';
import 'package:splitpay/views/profile/edit_upi.dart';
import 'package:splitpay/views/profile/sign_out.dart';

class Profile extends StatefulWidget {
  const Profile({ Key? key, this.uid, this.photoURL, this.name }) : super(key: key);
  final name;
  final uid;
  final photoURL;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool loading=true;
  Map ?user;

  @override
  void initState() {
    _getUser();
    super.initState();
  }

  _setUPI(upi){
    setState(() {
      user!['upi'] = upi;
    });
  }

  _getUser() async {
    var url = Uri.http(backend_url, '/v1/user/' + widget.uid);
    Response response = await http.get(url);
    user = json.decode(response.body);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),
                        child: CachedNetworkImage(
                          imageUrl: widget.photoURL,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              new CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              new Icon(Icons.error),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Text(
                      'hi, ' + widget.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 30,
                      ),
                    ),
                  ],
                ),
              ),
              Image(
                image: AssetImage('assets/images/profile.png'),
                width: 200,
              ),
            ],
          ),
          loading
          ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Loading(),
          )
          :Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 10,),
              Text(
                user!['upi'].split('@')[0],
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              Text(
                '@',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).accentColor,
                ),
              ),
              Text(
                user!['upi'].split('@')[1],
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              SizedBox(width: 10,),
              IconButton(
                onPressed: (){
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0))),
                    builder: (context) {
                      return EditUPI(upi: user!['upi'], uid: widget.uid, setUPI:_setUPI);
                  });
                },
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Divider(),
          InkWell(
            onTap: (){
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return AddFriend(uid: widget.uid);
                },
              );
            },
            child: ListTile(
              title: Text(
                'Add Friend',
                style: TextStyle(
                  fontSize: 21,
                ),
              ),
              trailing: Icon(
                Icons.person_add,
                color: Theme.of(context).accentColor,
              ),
            ),
          ),
          Divider(),
          InkWell(
            onTap: (){
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return AddGroup(uid: widget.uid);
                },
              );
            },
            child: ListTile(
              title: Text('Add Group',
                style: TextStyle(
                  fontSize: 21,
                ),
              ),
              trailing: Icon(
                Icons.group_add,
                size: 30,
                color: Theme.of(context).accentColor,
              ),
            ),
          ),
          Divider(),
          InkWell(
            child: ListTile(
                title: Text('Sign Out',
                  style: TextStyle(
                    fontSize: 21,
                  ),
                ),
                trailing: Icon(
                  Icons.logout,
                  color: Theme.of(context).accentColor,
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