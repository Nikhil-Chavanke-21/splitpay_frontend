// const backend_url='127.0.0.1:4000';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const backend_url='192.168.1.8:4000';

const upiExtensions=[
  'allbank',
  'aubank',
  'axisbank',
  'axl',
  'bandhan',
  'barodampay',
  'citi',
  'citigold',
  'dbs',
  'dlb',
  'federal',
  'freecharge',
  'hsbc',
  'ibl',
  'icici',
  'idbi',
  'idbi',
  'ikwik',
  'indianbank',
  'indus',
  'kbl',
  'kotak',
  'okaxis',
  'okhdfcbank',
  'okicici',
  'oksbi',
  'paytm',
  'rbl',
  'sbi',
  'sib',
  'uco',
  'upi',
  'ybl',
  'yesbank'
];

const categories=[
  'others',
  'food',
  'clothing',
  'grocery',
  'bills',
  'rent',
  'travel',
  'entertainment',
  'medical',
  'personal',
];

const categoryIcon={
  'others': Icons.more_horiz,
  'food': Icons.restaurant,
  'clothing': FontAwesomeIcons.tshirt,
  'grocery': Icons.shopping_cart,
  'bills': Icons.receipt,
  'rent': FontAwesomeIcons.home,
  'travel': Icons.train,
  'entertainment': FontAwesomeIcons.gamepad,
  'medical': FontAwesomeIcons.heartbeat,
  'personal': Icons.person,
};

var categoryColor = {
  'others': Colors.blue,
  'food': Colors.orangeAccent,
  'clothing': Colors.purple,
  'grocery': Colors.deepPurple,
  'bills': Colors.cyan,
  'rent': Colors.greenAccent,
  'travel': Colors.orange,
  'entertainment': Colors.deepPurple,
  'medical': Colors.redAccent,
  'personal': Colors.deepPurpleAccent,
};
