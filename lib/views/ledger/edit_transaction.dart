import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:select_form_field/select_form_field.dart';
import 'package:splitpay/config.dart';
import 'package:splitpay/views/components/loading.dart';

class EditTransaction extends StatefulWidget {
  const EditTransaction({ Key? key,
      this.category,
      this.description,
      this.amount,
      this.split,
      this.tid,
      this.payer,
      this.time,
      this.setIndex }) : super(key: key);

  final category;
  final description;
  final amount;
  final split;
  final tid;
  final payer;
  final time;
  final setIndex;

  @override
  State<EditTransaction> createState() => _EditTransactionState();
}

class _EditTransactionState extends State<EditTransaction> {
  bool loading=true;
  String _category='others';
  TextEditingController _amountController = TextEditingController();
  TextEditingController _description = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List memberList = [];
  List memberListPrev = [];
  Map _split={};
  int count = 0;

  @override
  void initState() {
    _category=widget.category;
    _description.text=widget.description;
    _amountController.text=widget.amount.toString();
    _split=widget.split;
    getMembers();
    super.initState();
  }

  getMembers() async {
    var friends=[];
    _split.forEach((key, value){
      if(value is int || value is double)friends.add(key);
      else value.forEach((key1, value1){
        friends.add(key1);
      });
    });
    var url = Uri.http(backend_url, '/v1/group/members/');
    var headers = {"content-type": "application/json"};
    var payload = {
      'friends': friends.join(','),
      'groups': '',
    };
    String body = jsonEncode(payload);
    Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    var names=json.decode(response.body);

    _split.forEach((key, value) {
      if (value is int || value is double) {
        if(value!=0)count+=1;
        memberList.add({
          'name': names[key],
          'id': key,
          'group': null,
          'isSelected': value!=0,
          'amount': value,
        });
      } else {
        value.forEach((key1, value1) {
          if(value1!=0)count+=1;
          memberList.add({
            'name': names[key1],
            'id': key1,
            'group': key,
            'isSelected': value1!=0,
            'amount': value1,
          });
        });
      }
    });
    memberListPrev=memberList;
    setState(() {
      loading=false;
    });
  }

  editExpense(amount) async {
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
    var url = Uri.http(backend_url, '/v1/expense/edit/');
    var headers = {"content-type": "application/json"};
    Map<String, dynamic> payload = {
      'description': _description.text,
      'prevSplit': widget.split,
      'split': split,
      'amount': amount,
      'category': _category,
      'tid': widget.tid,
      'time': widget.time.toString(),
      'payer': widget.payer,
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
      body: loading
      ? Loading()
      : Column(
        children: [
          SizedBox(
            height: 50.0,
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.deepPurpleAccent),
                ),
                child: Text(
                  "Edit",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    var amount = memberList
                        .map((element) => element['amount'])
                        .toList()
                        .reduce((a, b) => a + b);
                    var _amount=double.parse(_amountController.text);
                    if (amount != _amount){
                      Fluttertoast.showToast(
                          msg: "Split doesn't add to amount",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black87,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    } else {
                      await editExpense(_amount);
                      widget.setIndex();
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List<Widget>.from(categories.map((entry) {
                return _category==entry?
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.deepPurpleAccent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: Theme.of(context).primaryColorLight,
                          child: Icon(
                            categoryIcon[entry],
                            size: 15,
                            color: categoryColor[entry],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                          child: Text(entry, style: TextStyle(color: Colors.deepPurpleAccent),),
                        ),
                      ],
                    ),
                  ),
                ):
                InkWell(
                  onTap: (){
                    setState(() {
                      _category=entry;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      radius: 15,
                      child: Icon(
                        categoryIcon[entry],
                        size: 15,
                        color: categoryColor[entry],
                      ),
                    ),
                  ),
                );
              })),
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    child: TextFormField(
                      controller: _description,
                      keyboardType: TextInputType.text,
                      validator: (val) {
                        return val!.isEmpty
                            ? "Please enter description"
                            : null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Description',
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 10.0),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        return val!.isEmpty
                            ? "Please enter upi id"
                            : double.parse(val.toString()) == 0
                                ? "Amount can't be 0"
                                : null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 10.0),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 35),
              child: IconButton(
                icon: Icon(
                  FontAwesomeIcons.equals,
                  color: Theme.of(context).accentColor,
                ),
                onPressed: () {
                  setState(() {
                    for (int i = 0; i < memberList.length; i++) {
                      if (memberList[i]['isSelected'])
                        memberList[i]['amount'] = double.parse(_amountController.text) / count;
                    }
                  });
                },
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
        ],
      ),
    );
  }

  Widget SplitItem(String name, bool isSelected, amount, int index) {
    TextEditingController _amountTextController = TextEditingController();
    _amountTextController.text = amount.toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
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
              color: memberList[index]['isSelected']
                  ? Colors.black
                  : Colors.grey,
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
                      color: memberList[index]['isSelected']
                          ? Colors.black
                          : Theme.of(context).canvasColor,
                    ),
                    onEditingComplete: () {
                      setState(() {
                        memberList[index]['amount'] =
                            double.parse(_amountTextController.text);
                      });
                    },
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    controller: _amountTextController,
                    cursorColor: Theme.of(context).accentColor,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 10.0),
                    ),
                  ),
                ),
                SizedBox(
                  width: 40.0,
                  child: IconButton(
                    icon: Icon(
                      Icons.format_color_fill,
                      color: memberList[index]['isSelected']
                          ? Theme.of(context).accentColor
                          : Theme.of(context).canvasColor,
                    ),
                    onPressed: () {
                      if (memberList[index]['isSelected']) {
                        setState(() {
                          double remainingAmount = memberList
                              .where((element) => element['isSelected'])
                              .toList()
                              .map((element) => element['amount'])
                              .toList()
                              .reduce((a, b) => a + b);
                          memberList[index]['amount'] +=
                              double.parse(_amountController.text) - remainingAmount;
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
    );
  }
}