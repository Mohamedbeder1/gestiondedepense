import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

List<Map<String, dynamic>> transData = [
  {
    'icon': FaIcon(FontAwesomeIcons.burger, color: Colors.white),
    'color': Colors.yellow[700],
    'name': 'food',
    'totalAmount': '\$-3.00',
    'date': 'today',
  },
  {
    'icon': FaIcon(FontAwesomeIcons.bagShopping, color: Colors.white),
    'color': Colors.purple,
    'name': 'shoping',
    'totalAmount': '\$-13.00',
    'date': 'today',
  },
  {
    'icon': FaIcon(FontAwesomeIcons.heartCircleCheck, color: Colors.white),
    'color': Colors.green,
    'name': 'health',
    'totalAmount': '\$-20.00',
    'date': 'today',
  },
  {
    'icon': FaIcon(FontAwesomeIcons.plane, color: Colors.white),
    'color': Colors.blue,
    'name': 'playing',
    'totalAmount': '\$-10.00',
    'date': 'today',
  },
];
