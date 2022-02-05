import 'package:flutter/material.dart';
import 'package:splitpay/views/checkout.dart';
import 'package:upi_india/upi_india.dart';
import 'package:intent/intent.dart' as android_intent;
import 'package:intent/action.dart' as android_action;

class Detail extends StatefulWidget {
  Detail({ Key? key, this.url }) : super(key: key);
  final url;

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  Map fields={};
  TextEditingController _amountController=TextEditingController();

  Future<UpiResponse>? _transaction;
  UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;

  TextStyle header = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  TextStyle value = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  @override
  void initState() {
    fields = splitQueryString(widget.url.code.split('?')[1]);
    if(fields['pa']==null || fields['pn']==null){
      print('No Upi id found');
    } else if (fields['sign']==null){
      print('Given Merchhant Account is insecure');
    }
    fields['mode']='02';
    fields['cu']='INR';
    // am=ENTER
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e) {
      apps = [];
    });
    
    super.initState();
  }

  Map<String, String> splitQueryString(String query) {
    return query.split("&").fold({}, (map, element) {
      int index = element.indexOf("=");
      if (index == -1) {
        if (element != "") {
          map[element] = "";
        }
      } else if (index != 0) {
        var key = element.substring(0, index);
        var value = element.substring(index + 1);
        map[key] = value.replaceAll('%20', ' ');
      }
      return map;
    });
 }

  // Future<UpiResponse> initiateTransaction(UpiApp app) async {
  //   return _upiIndia.startTransaction(
  //     app: app,
  //     receiverUpiId: fields['pa'],
  //     receiverName: fields['pn'],
  //     transactionRefId: fields['tr']!=null? fields['tr']:'',
  //     // transactionNote: '',
  //     merchantSign: fields['sign'],
  //     amount: double.parse(_amountController.text),
  //   );
  // }

  Widget displayUpiApps() {
    if (apps == null)
      return Center(child: CircularProgressIndicator());
    else if (apps!.length == 0)
      return Center(
        child: Text(
          "No apps found to handle transaction.",
          style: header,
        ),
      );
    else
      return Padding(
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Wrap(
              children: apps!.map<Widget>((UpiApp app) {
                return GestureDetector(
                  onTap: () {
                    if(_amountController.text.length==0 || double.parse(_amountController.text)==0){
                      print('Please enter a amount');
                    }
                    // android_intent.Intent()
                    // ..setPackage(app.packageName)
                    // ..setAction(android_action.Action.ACTION_VIEW)
                    // ..setData(Uri.parse(widget.url.code+'&mode=02&cu=INR&am='+double.parse(_amountController.text).toString()))
                    // ..startActivity().catchError((e) => print(e));
                    // 9422252553@postbank
                    // RANGNATH SANTU CHAVANKE
                    // null
                    // 1.0
                    // 2021-11-18 06:08:50.796959
                    // com.google.android.apps.nbu.paisa.user
                    Navigator.pushReplacement(context, new MaterialPageRoute(
                      settings: const RouteSettings(name: '/form'),
                      builder: (context) => new CheckOut(
                        upi: fields['pa'],
                        merchant: fields['pn'],
                        mc: fields['mc'],
                        am: double.parse(_amountController.text),
                        date: DateTime.now(),
                        app: app.packageName,
                      ),
                    ));
                  },
                  child: Container(
                    height: 80,
                    width: 70,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.memory(
                          app.icon,
                          height: 60,
                          width: 60,
                        ),
                        Text(app.name),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
  }

  String _upiErrorHandler(error) {
    switch (error) {
      case UpiIndiaAppNotInstalledException:
        return 'Requested app not installed on device';
      case UpiIndiaUserCancelledException:
        return 'You cancelled the transaction';
      case UpiIndiaNullResponseException:
        return 'Requested app didn\'t return any response';
      case UpiIndiaInvalidParametersException:
        return 'Requested app cannot handle the transaction';
      default:
        return 'An Unknown error has occurred';
    }
  }

  void _checkTxnStatus(String status) {
    switch (status) {
      case UpiPaymentStatus.SUCCESS:
        print('Transaction Successful');
        break;
      case UpiPaymentStatus.SUBMITTED:
        print('Transaction Submitted');
        break;
      case UpiPaymentStatus.FAILURE:
        print('Transaction Failed');
        break;
      default:
        print('Received an Unknown transaction status');
    }
  }

  Widget displayTransactionData(title, body) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title: ", style: header),
          Flexible(
              child: Text(
            body,
            style: value,
          )),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(height: 40.0,),
          Text('Paying', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          SizedBox(height: 10.0,),
          Text(fields['pn'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          Text(fields['pa'], style: TextStyle(fontSize: 20),),
          SizedBox(height: 10.0,),
          Text('Amount', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 110.0),
            child: TextFormField(
              controller:_amountController,
              keyboardType: TextInputType.number,
              keyboardAppearance: Brightness.dark,
              style: TextStyle(
                fontSize: 28,
              ),
              decoration: InputDecoration(
                hintText: '₹',
              ),
            ),
          ),
          SizedBox(height: 10.0,),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Pay using', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
            ),
          ),
          Expanded(
            child: displayUpiApps(),
          ),
          Expanded(
            child: FutureBuilder(
              future: _transaction,
              builder: (BuildContext context, AsyncSnapshot<UpiResponse> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        _upiErrorHandler(snapshot.error.runtimeType),
                        style: header,
                      ), // Print's text message on screen
                    );
                  }

                  // If we have data then definitely we will have UpiResponse.
                  // It cannot be null
                  UpiResponse _upiResponse = snapshot.data!;

                  // Data in UpiResponse can be null. Check before printing
                  String txnId = _upiResponse.transactionId ?? 'N/A';
                  String resCode = _upiResponse.responseCode ?? 'N/A';
                  String txnRef = _upiResponse.transactionRefId ?? 'N/A';
                  String status = _upiResponse.status ?? 'N/A';
                  String approvalRef = _upiResponse.approvalRefNo ?? 'N/A';
                  _checkTxnStatus(status);

                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        displayTransactionData('Transaction Id', txnId),
                        displayTransactionData('Response Code', resCode),
                        displayTransactionData('Reference Id', txnRef),
                        displayTransactionData('Status', status.toUpperCase()),
                        displayTransactionData('Approval No', approvalRef),
                      ],
                    ),
                  );
                } else
                  return Center(
                    child: Text(''),
                  );
              },
            ),
          )
        ],
      ),
    );
  }
}