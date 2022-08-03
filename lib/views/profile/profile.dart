import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:splitpay/config.dart';
import 'package:splitpay/views/components/loading.dart';
import 'package:splitpay/views/profile/add_friend.dart';
import 'package:splitpay/views/profile/add_group.dart';
import 'package:splitpay/views/profile/edit_upi.dart';
import 'package:splitpay/views/profile/sign_out.dart';
import 'package:splitpay/views/theme_provider.dart';

class Profile extends StatefulWidget {
  const Profile({ Key? key, this.uid, this.photoURL }) : super(key: key);
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
      appBar: NeumorphicAppBar(
        title: Text('Profile'),
        centerTitle: true,
        actions: [
          NeumorphicRadio(
            onChanged: (val) {
              final provider =
                  Provider.of<ThemeProvider>(context, listen: false);
              provider.toggleTheme(NeumorphicTheme.isUsingDark(context));
            },
            style: NeumorphicRadioStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.circle(),
            ),
            child: Icon(
              Icons.brightness_6,
              color: Theme.of(context).accentColor,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: CachedNetworkImage(
                imageUrl: widget.photoURL,
                fit: BoxFit.cover,
                placeholder: (context, url) => new CircularProgressIndicator(),
                errorWidget: (context, url, error) => new Icon(Icons.error),
              ),
            ),
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
                  color: Colors.white70,
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
                  color: Colors.white70,
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
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Neumorphic(
              child: InkWell(
                onTap: (){
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return AddFriend(uid: widget.uid);
                    },
                  );
                },
                child: ListTile(
                  title: Text('Add Friend'),
                  trailing: Icon(
                    Icons.person_add,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Neumorphic(
              child: InkWell(
                onTap: (){
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return AddGroup(uid: widget.uid);
                    },
                  );
                },
                child: ListTile(
                  title: Text('Add Group'),
                  trailing: Icon(
                    Icons.group_add,
                    size: 30,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Neumorphic(
              child: InkWell(
                child: ListTile(
                    title: Text('Sign Out'),
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
            ),
          ),
        ],
      ),
    );
  }
}