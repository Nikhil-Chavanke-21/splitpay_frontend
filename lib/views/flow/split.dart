import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:splitpay/config.dart';
import 'package:splitpay/views/components/loading.dart';

class Split extends StatefulWidget {
  const Split({ Key? key, this.members, this.amount, this.tid, this.uid }) : super(key: key);
  final members;
  final amount;
  final tid;
  final uid;

  @override
  _SplitState createState() => _SplitState();
}

class _SplitState extends State<Split> {
  Map ?members;
  Map split={};
  int count=1;
  List memberList=[];
  String spliting='equal';

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
        'name': 'Nikhil Chavanke',
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

    memberList.forEach((member) {
      if (member['group'] != null) {
        if (split.containsKey(member['group']))
          split[member['group']][member['id']] = member['amount'];
        else
          split[member['group']] = {
            member['id']: member['amount'],
          };
      } else
        split[member['id']] = member['amount'];
    });
    var url = Uri.http(backend_url, '/v1/expense/split/');
    var headers = {"content-type": "application/json"};
    Map<String, dynamic> payload = {
      'transactionId': widget.tid,
      'payer': widget.uid,
      'members': split,
    };
    String body = jsonEncode(payload);
    Response response = await http.post(
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
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: CustomRadioButton(
                        margin: EdgeInsets.all(15.0),
                        enableButtonWrap: true,
                        width: 120.0,
                        height: 50.0,
                        radius: 20,
                        shapeRadius: 20,
                        absoluteZeroSpacing: true,
                        elevation: 0.0,
                        selectedBorderColor: Colors.deepPurpleAccent,
                        unSelectedBorderColor: Colors.deepPurpleAccent,
                        selectedColor: Colors.deepPurpleAccent,
                        unSelectedColor: Theme.of(context).canvasColor,
                        defaultSelected: spliting,
                        buttonLables: ['Equal', 'Unequal'],
                        buttonValues: ['equal', 'unequal'],
                        buttonTextStyle: ButtonTextStyle(
                          selectedColor: Theme.of(context).canvasColor,
                          unSelectedColor: Colors.deepPurpleAccent,
                          textStyle: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        radioButtonValue: (value) {
                          setState(() {
                            spliting = value.toString();
                            if(spliting=='equal'){
                              for(int i=0;i<memberList.length;i++){
                                if(memberList[i]['isSelected'])memberList[i]['amount']=widget.amount/count;
                              }
                            }
                          });
                        },
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
    return ListTile(
      title: Text(
        name,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      leading: IconButton(
            onPressed: (){
              setState(() {
                memberList[index]['isSelected'] = !memberList[index]['isSelected'];
                if(memberList[index]['isSelected'] == true)count+=1;
                else if (memberList[index]['isSelected'] == false){
                  count-=1;
                  memberList[index]['amount']=0.0;
                }
                if(spliting=='equal'){
                  for(int i=0;i<memberList.length;i++){
                    if(memberList[i]['isSelected'])memberList[i]['amount']=widget.amount/count;
                  }
                };
              });
            },
            icon: Icon(
              isSelected?Icons.check_circle:Icons.check_circle_outline,
              color: Colors.deepPurpleAccent,
            ),
          ),
      trailing: SizedBox(
        width: 130.0,
        child: Row(
          children: [
            SizedBox(
              width: 40.0,
              child: IconButton(
                icon: Icon(Icons.format_color_fill, color: Colors.deepPurpleAccent),
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
            SizedBox(
              width: 90.0,
              child: TextFormField(
                onEditingComplete: (){
                  setState(() {
                    memberList[index]['amount']=double.parse(_amountTextController.text);
                  });
                },
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                controller: _amountTextController,
                cursorColor: Colors.deepPurpleAccent,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.deepPurpleAccent,
                      width: 3.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.deepPurpleAccent,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}