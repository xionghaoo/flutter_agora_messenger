import 'package:flutter/material.dart';

class CallingPage extends StatefulWidget {
  final bool _isCaller;
  CallingPage(this._isCaller);
  @override
  _CallingPageState createState() => _CallingPageState();
}

class _CallingPageState extends State<CallingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget._isCaller ? "正在呼叫。。。" : "有新的呼叫邀请。。。"),
          SizedBox(height: 20,),
          TextButton(
              onPressed: () {

              },
              child: Text(widget._isCaller ? "挂断" : "接听")
          ),
          SizedBox(height: 10,),
          widget._isCaller
              ? SizedBox()
              : TextButton(
              onPressed: () {

              },
              child: Text("挂断")
          )
        ],
      ),
    );
  }
}