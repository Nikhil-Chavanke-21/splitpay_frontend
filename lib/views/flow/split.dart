import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:splitpay/config.dart';
import 'package:splitpay/models/user.dart';
import 'package:splitpay/views/theme_provider.dart';

class Split extends StatefulWidget {
  const Split({ Key? key, this.members, this.amount, this.uid, this.name, this.description, this.category, this.upiApp, this.payeeName, this.payeeUpi }) : super(key: key);
  final members;
  final amount;
  final description;
  final category;
  final upiApp;
  final payeeName;
  final payeeUpi;
  final uid;
  final name;

  @override
  _SplitState createState() => _SplitState();
}

class _SplitState extends State<Split> {
  Map ?members;
  Map split={};
  int count=1;
  List memberList=[];

  @override
  void initState() {
    members=widget.members;
    widget.members.forEach((key, value){
      if(value is String){
        split[key]=0;
        memberList.add({
          'name': value,
          'id': key,
          'group': null,
          'isSelected': true,
        });
      }
      else {
        split[key]={};
        value.forEach((key1, value1){
          split[key][key1]=0;
          memberList.add({
            'name': value1,
            'id': key1,
            'group': key,
            'isSelected': true,
          });
        });
      }
    });
    if(memberList.where((element) => element['id']==widget.uid).length==0){
      memberList.add({
        'name': widget.name,
        'id': widget.uid,
        'group': null,
        'isSelected': true,
      });
    }
    count=memberList.length;
    memberList.forEach((element) {
      element['amount']=widget.amount/count;
    });
    super.initState();
  }

  splitExpense() async {
    Map<String, dynamic> split = {};
    Map<String, dynamic> zeros = {};

    memberList.forEach((member) {
      if(member['amount']!=0){
        if (member['group'] != null) {
          if (split.containsKey(member['group']))
            split[member['group']][member['id']] = member['amount'];
          else
            split[member['group']] = {
              member['id']: member['amount'],
            };
        } else
          split[member['id']] = member['amount'];
      } else {
        zeros[member['id']] = member['group'];
      }
    });
    var url = Uri.http(backend_url, '/v1/expense/split/');
    var headers = {"content-type": "application/json"};
    Map<String, dynamic> payload = {
      'payer': widget.uid,
      'name': widget.name.split(' ')[0],
      'description': widget.description,
      'members': split,
      'zeros': zeros,
      'amount': widget.amount,
      'payeeUpi': widget.payeeUpi,
      'payeeName': widget.payeeName,
      'upiApp': widget.upiApp,
      'category': widget.category,
    };
    String body = jsonEncode(payload);
    await http.post(
      url,
      headers: headers,
      body: body,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Split')),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: SafeArea(
              child: Container(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 35),
                        child: NeumorphicRadio(
                          padding: EdgeInsets.all(15),
                          onChanged: (val) {
                            setState(() {
                              for (int i = 0; i < memberList.length; i++) {
                                if (memberList[i]['isSelected'])
                                  memberList[i]['amount'] = widget.amount / count;
                              }
                            });
                          },
                          style: NeumorphicRadioStyle(
                            shape: NeumorphicShape.flat,
                            boxShape: NeumorphicBoxShape.circle(),
                          ),
                          child: Icon(
                            FontAwesomeIcons.equals,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: memberList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SplitItem(
                            memberList[index]['name'],
                            memberList[index]['isSelected'],
                            memberList[index]['amount'],
                            index,
                          );
                        }),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 25,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurpleAccent),
                          ),
                          child: Text(
                            "Split",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          onPressed: () async {
                            double amount=memberList.map((element)=>element['amount']).toList().reduce((a, b) => a + b);
                            if(amount!=widget.amount)print("Split doesn't add to amount");
                            else{
                              await splitExpense();
                              Navigator.pop(context);
                              print("Splitted------------------------------");
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget SplitItem(String name, bool isSelected, double amount, int index) {
    TextEditingController _amountTextController = TextEditingController();
    _amountTextController.text=amount.toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Neumorphic(
        style: NeumorphicStyle(
          shadowLightColor: memberList[index]['isSelected']? Colors.grey:NeumorphicTheme.baseColor(context),
        ),
        child: InkWell(
          onTap: (){
            setState(() {
              memberList[index]['isSelected'] =
                  !memberList[index]['isSelected'];
              if (memberList[index]['isSelected'] == true)
                count += 1;
              else if (memberList[index]['isSelected'] == false) {
                count -= 1;
                memberList[index]['amount'] = 0.0;
              }
            });
          },
          child: ListTile(
            title: Text(
              name,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
                color: memberList[index]['isSelected']?Colors.white:Colors.grey,
              ),
            ),
            trailing: SizedBox(
              width: 130.0,
              child: Row(
                children: [
                  SizedBox(
                    width: 90.0,
                    child: TextFormField(
                      style: TextStyle(
                        color: memberList[index]['isSelected']?Colors.white: Theme.of(context).canvasColor,
                      ),
                      onEditingComplete: (){
                        setState(() {
                          memberList[index]['amount']=double.parse(_amountTextController.text);
                        });
                      },
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      controller: _amountTextController,
                      cursorColor: Theme.of(context).accentColor,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40.0,
                    child: IconButton(
                      icon: Icon(
                        Icons.format_color_fill,
                        color: memberList[index]['isSelected']?Theme.of(context).accentColor:Theme.of(context).canvasColor,
                      ),
                      onPressed: () {
                        if(memberList[index]['isSelected']){
                          setState(() {
                            double remainingAmount=memberList.where((element) => element['isSelected']).toList().map((element)=>element['amount']).toList().reduce((a,b)=>a+b);
                            memberList[index]['amount']+=widget.amount-remainingAmount;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}