import 'dart:convert';

// import 'package:api_cache_manager/models/cache_db_model.dart';
// import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:splitpay/views/components/loading.dart';
import 'package:splitpay/views/ledger/friend_logs.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:splitpay/config.dart';
import 'package:splitpay/views/ledger/group_logs.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Groups extends StatefulWidget {
  const Groups({Key ?key, this.uid}) : super(key: key);
  final uid;

  @override
  _GroupsState createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  bool loading=true;
  List ?contacts;

  @override
  void initState() {
    // TODO: implement initState
    _getContacts();
    super.initState();
  }

  _getContacts() async {

    // var isCacheExist= await APICacheManager().isAPICacheKeyExist('groups');
    // if(!isCacheExist){
      var url=Uri.http(backend_url, '/v1/user/contacts/' + widget.uid);
      Response response = await http.get(url);
      // APICacheDBModel cacheDBModel = new APICacheDBModel(
      //   key: "groups",
      //   syncData: response.body,
      // );
      // await APICacheManager().addCacheData(cacheDBModel);
      contacts = json.decode(response.body);
    // } else {
    //   var cacheData=await APICacheManager().getCacheData("groups");
    //   contacts=json.decode(cacheData.syncData);
    // }
    setState(() {
      loading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
      ),
      body: loading == true
          ? Loading()
          : RefreshIndicator(
            onRefresh: () async{
              setState(() {
                loading=true;
              });
              await _getContacts();
            },
            child: SafeArea(
              child: Container(
                child: Expanded(
                  child: ListView.builder(
                      itemCount: contacts!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return MemberItem(
                          contacts![index]['id'],
                          contacts![index]['name'],
                          contacts![index]['photoURL'],
                          contacts![index]['isGroup'],
                          index,
                        );
                      }),
                ),
              ),
            ),
          ),
    );
  }
  Widget MemberItem(
      String id, String name, String photoURL, bool isGroup, int index) {
    return ListTile(
      leading: photoURL!=null ?
      Container(
        width: 44,
        height: 44,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: CachedNetworkImage(
            imageUrl: photoURL,
            fit: BoxFit.cover,
            placeholder: (context, url) => new CircularProgressIndicator(),
            errorWidget: (context, url, error) => new Icon(Icons.error),
          ),
        ),
      ):isGroup?CircleAvatar(
        radius: 22,
        backgroundColor: Colors.green[700],
        child: Icon(
          Icons.group_outlined,
          color: Colors.white,
        ),
      ):CircleAvatar(
        radius: 22,
        backgroundColor: Colors.green[700],
        child: Icon(
          Icons.person_outline_outlined,
          color: Colors.white,
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>
        isGroup?
        GroupLogs(
          id: id,
          name: name,
          photoURL: photoURL,
          uid: widget.uid,
        ):
        FriendLogs(
          id: id,
          name: name,
          photoURL: photoURL,
          upi: contacts![index]['upi'],
          due: contacts![index]['due'],
          uid: widget.uid,
        )));
      },
    );
  }
}

