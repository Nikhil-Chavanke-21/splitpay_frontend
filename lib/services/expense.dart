import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:splitpay/models/expense.dart';

class ExpenseDatabase {
  final String ?eid;
  ExpenseDatabase({this.eid});

  final CollectionReference orderCollection =
      FirebaseFirestore.instance.collection('order');

  List<ExpenseData> _orderListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return ExpenseData(
        eid: doc.id,
        uid: doc.data()['uid'],
        amount: doc.data()['amount'],
      );
    }).toList();
  }

  // Stream<List<Expense>> pendingExpenses() {
  //   return orderCollection
  //       .where('status', isEqualTo: 'pending')
  //       .snapshots()
  //       .map(_orderListFromSnapshot);
  // }

  // Stream<List<Expense>> completedExpenses() {
  //   return orderCollection
  //       .where('status', isEqualTo: 'completed')
  //       .snapshots()
  //       .map(_orderListFromSnapshot);
  // }

  Future addExpense(String client, String address, String contact, String type,
      Map service, String asignee) async {
    return await orderCollection.doc().set({
      'client': client,
      'address': address,
      'contact': contact,
      'type': type,
      'service': service,
      'status': 'pending',
      'asignee': asignee,
    });
  }

  Future updateExpense(String client, String address, String contact, String type,
      Map service, String asignee) async {
    return await orderCollection.doc(eid).update({
      'client': client,
      'address': address,
      'contact': contact,
      'type': type,
      'service': service,
      'asignee': asignee,
    });
  }

  Future deleteExpense() async {
    return await orderCollection.doc(eid).delete();
  }
}