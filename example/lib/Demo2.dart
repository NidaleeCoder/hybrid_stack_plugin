import 'package:flutter/material.dart';
import 'package:hybrid_stack_plugin/hybrid_stack_plugin.dart';
import 'package:hybrid_stack_plugin_example/main.dart';


class Demo2 extends StatefulWidget {
  final int pageId;
  Demo2({this.pageId});
  @override
  State<StatefulWidget> createState() {
    return _Demo2();
  }

}

class _Demo2 extends State<Demo2> {
  @override
  Widget build(BuildContext context) {
    int pid = widget.pageId;
    print("demo2 page: $pid");
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('flutter page id=$pid'),
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
            Navigator.of(context).pop("I am message from flutter example");
          },),
        ),
        body: Center(
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: Text('This is a Flutter Page, Demo2'),
                ),
                ListTile(
                  title: Text('Open Flutter Page'),
                  onTap: () {
                    pid++;
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return MyApp(pageId: pid,);
                    }));
                  },
                ),
                ListTile(
                  title: Text('Open Native Page'),
                  onTap: () async {
                    var result = await HybridStackPlugin.instance.pushNativePage("demo2", {});
                    print("demo2 native result： $result");
                  },
                )
              ],
            )
        ),
      ),
    );
  }

}