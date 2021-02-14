import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
/*
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
*/

      home: MyHomePage(theTitle: 'My expenses'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.theTitle}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String theTitle;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final formkey = GlobalKey<FormState>();
  TextEditingController description = new TextEditingController();
  TextEditingController amount = new TextEditingController();
  //TextEditingController currency = new TextEditingController();
  int currencyCode = 1;
  String currency;
  String dDate;
  int expTypeCode =1;
  String expType;
  DateFormat dateFormat = DateFormat('dd-MMM-yyyy');
  String oldExpList;
  String newExpLog;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

/*
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.theTitle),
      ),
      body: Container(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
        child: Form(
          key: formkey,
          child: Column(
            children: [
              TextFormField(
                controller: description,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(hintText: "description"),
              ),
              SizedBox(height: 40),

              TextFormField(
                controller: amount,
                decoration: InputDecoration(hintText: "amount"),
              ),
              SizedBox(height: 40),

            GestureDetector(
              onTap: () {
                showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2019),
                    lastDate: DateTime (2023)
                ).then((date){
                  setState(() {
                    date != null? dDate = dateFormat.format(date):null;
                  });
                });

              },
              child: Icon(
                Icons.access_time,
                color: Colors.blue,
                size: 50.0,
              ),

            ),

              //Text (DateTime.now().toString()),
            ],

          )

        )

      ),


      floatingActionButton: FloatingActionButton(
        onPressed: () {writeData ();},
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );

*/

    Future getExpList() async {
      await Firestore.instance
          .collection("Expenses")
          .document("records")
          .get()
          .then((value) {
        if (value.data != null) {
          if (value.data['items'] != null) {
            List msgLogList = value.data['items'];
            int len = msgLogList.length;
            oldExpList = "";
            for (int x = 0; x < len; ++x) {
              newExpLog =
                  msgLogList.sublist(x, x + 1).single + "\n" + oldExpList;
              oldExpList = newExpLog;
            }
          }
        }
      });
      setState(() {});
    }

    getExpList();

    writeData() {
      //description == null ? description == "default" : null;
      //description == "testing";

      Map<String, String> spendMap = {
        "Amount SGD": amount.text,
        "Spend on": description.text,
        "When": dDate.toString(),
      };
      Firestore.instance.collection("Expenses").document("records").updateData({
        "items": FieldValue.arrayUnion([
          dDate.toString() +
              " - $expType" +
              " - $currency " +
              amount.text +
              " - " +
              description.text
        ])
      });
      amount.clear();
      description.clear();

      //getExpList();
    }

    Future uploadExp() async {
      switch (currencyCode) {
        case 1:
          currency = "SGD";
          break;
        case 2:
          currency = "MYR";
      }

      switch (expTypeCode) {
        case 1:
           expType = "OFC";
          break;
        case 2:
          expType = "PSN";
      }

      await writeData();
      await getExpList();
      //setState(() {});
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(widget.theTitle),
        ),
        //automaticallyImplyLeading: true,
        body: Builder(
            builder: (context) => Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Form(
                    key: formkey,
                    child: Column(children: [
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [

                            Expanded (flex:4,
                              child: DropdownButton(
                                  underline: SizedBox(),
                                  value: expTypeCode,
                                  items: [
                                    DropdownMenuItem(
                                      child: Text(
                                        "OFC",
                                        style: TextStyle(
                                            color: Colors.blue, fontSize: 12),
                                      ),
                                      value: 1,
                                    ),
                                    DropdownMenuItem(
                                      child: Text(
                                        "PSN",
                                        style: TextStyle(
                                            color: Colors.blue, fontSize: 12),
                                      ),
                                      value: 2,
                                    ),
                                  ],
                                  onChanged: (value) {
                                    //setState(() {
                                      expTypeCode = value;
                                    //});
                                  }),

                            ),


                            Expanded(
                              flex: 16,
                              child: TextFormField(
                                style: TextStyle(color: Colors.blue),
                                controller: description,
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "description",
                                  hintStyle: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[400],
                                      fontStyle: FontStyle.italic),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      //SizedBox(height: 40),
                      Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: DropdownButton(
                                    underline: SizedBox(),
                                    value: currencyCode,
                                    items: [
                                      DropdownMenuItem(
                                        child: Text(
                                          "SGD",
                                          style: TextStyle(
                                              color: Colors.blue, fontSize: 12),
                                        ),
                                        value: 1,
                                      ),
                                      DropdownMenuItem(
                                        child: Text(
                                          "MYR",
                                          style: TextStyle(
                                              color: Colors.blue, fontSize: 12),
                                        ),
                                        value: 2,
                                      ),
                                    ],
                                    onChanged: (value) {
                                      //setState(() {
                                        currencyCode = value;
                                      //});
                                    }),
                              ),
                              Expanded(
                                flex: 10,
                                child: TextFormField(
                                  style: TextStyle(color: Colors.blue),
                                  controller: amount,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "amount",
                                    hintStyle: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[400],
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: dDate != null
                                    ? Text(
                                        dDate.toString(),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(color: Colors.blue),
                                      )
                                    : Text(""),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 1,
                                child: GestureDetector(
                                  onTap: () {
                                    showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2019),
                                            lastDate: DateTime(2023))
                                        .then((date) {
                                      //setState(() {
                                      date != null
                                          ? dDate = dateFormat.format(date)
                                          : null;
                                      //});
                                    });
                                  },
                                  child: Icon(
                                    Icons.access_time,
                                    color: Colors.blue,
                                    size: 30.0,
                                  ),
                                ),
                              )
                            ],
                          )),
                      SizedBox(
                        height: 20,
                      ),

                      FlatButton(
                        /////// to fix ///////
                        onPressed: () {
                          amount.toString() != "" ? uploadExp() : null;
                        },
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Text(
                          "Save",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 20,
                      ),

                      Expanded(
                          flex: 10,
                          child: new SingleChildScrollView(
                            reverse: false,
                            scrollDirection: Axis.vertical, //.horizontal
                            //padding: const EdgeInsets.all(5.0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 10),
                                child: newExpLog != null
                                    ? Text(
                                        newExpLog,
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.left,
                                      )
                                    : Text(""),
                              ),
                            ),
                          ))
                    ])))));
  }
}
