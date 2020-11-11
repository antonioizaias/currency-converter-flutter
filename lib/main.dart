import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'utils/key_util.dart' as key;

void main() => runApp(MyApp());

Future<Map> _getData() async {
  http.Response response = await http.get(key.request);
  return json.decode(response.body);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conversor de Moedas',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Conversor de Moedas'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController rCtrl = TextEditingController();
  final TextEditingController dCtrl = TextEditingController();
  final TextEditingController eCtrl = TextEditingController();

  double dolar = 0.0;
  double euro = 0.0;

  void realChanged(String text) {
    if (text.isEmpty) {
      clearAll();
    }
    double realConvert = double.parse(text);
    dCtrl.text = (realConvert / dolar).toStringAsFixed(2);
    eCtrl.text = (realConvert / euro).toStringAsFixed(2);
  }

  void dolarChanged(String text) {
    if (text.isEmpty) {
      clearAll();
    }
    double dolarConvert = double.parse(text);
    rCtrl.text = (dolarConvert * dolar).toStringAsFixed(2);
    eCtrl.text = (dolarConvert * dolar / euro).toStringAsFixed(2);
  }

  void euroChanged(String text) {
    if (text.isEmpty) {
      clearAll();
    }
    double euroConvert = double.parse(text);
    rCtrl.text = (euroConvert * euro).toStringAsFixed(2);
    dCtrl.text = (euroConvert * euro / dolar).toStringAsFixed(2);
  }

  void clearAll() {
    rCtrl.clear();
    dCtrl.clear();
    eCtrl.clear();
  }

  Widget buildTextFormField(var label, var prefix, var ctrl, Function func) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      style: TextStyle(
        color: Colors.deepPurple,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.deepPurple,
        ),
        border: OutlineInputBorder(),
        prefix: Text(
          prefix,
          style: TextStyle(
            color: Colors.deepPurple,
          ),
        ),
      ),
      onChanged: func,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: _getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados...",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 25.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar os dados!",
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 25.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data['results']['currencies']['USD']['buy'];
                euro = snapshot.data['results']['currencies']['EUR']['buy'];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 120.0,
                        color: Colors.deepPurple,
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      buildTextFormField("BRL", "R\$ ", rCtrl, realChanged),
                      SizedBox(
                        height: 10.0,
                      ),
                      buildTextFormField("USD", "US\$ ", dCtrl, dolarChanged),
                      SizedBox(
                        height: 10.0,
                      ),
                      buildTextFormField("EUR", "€ ", eCtrl, euroChanged),
                      SizedBox(
                        height: 10.0,
                      ),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}
