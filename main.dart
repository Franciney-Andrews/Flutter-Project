import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Persistência de dados',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
      ),
      home: const MyHomePage(title: 'Sign Up'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repasswordController = TextEditingController();
  String status = "";
  Color? corErro = Colors.red[500];
  Color? corSucesso = Colors.green[700];
  Color? corResultado;

  Future<Database> _openBanco() async {
    try{
      print('Executando a função openBanco()');
      var databasePath = await getDatabasesPath();
      String path = join(databasePath, 'banco.db');

      Database db = await (openDatabase(path, version: 1, onCreate: (db, versaoRecente) async {
        String sql = "CREATE TABLE USERS(email VARCHAR(30), password VARCHAR(16))";
        await db.execute(sql);
      }));
      print('Banco: ${db.isOpen.toString()}');
      return db;
    }
    catch(ex){
      setState(() {
        status = 'Erro ao cadastrar usuário no banco de dados';
      });
      throw Exception();
    }
  }

  bool _validaEmail(String email){
    if(email.isEmpty || email.length > 30 || email.contains("@")){
      status = "Email é inválido!";
      return false;
    }
    return true;
  }

  bool _validaSenha(String password, String repassword){

    if(password.isEmpty || password.length > 16){
      status = "Senha inválida";
      return false;
    }

    if(repassword != password){
      status = "As senhas estão diferentes!";
      return false;
    }
    return true;
  }

  void _salvar() async {
    String email = emailController.text;
    String password = passwordController.text;
    String repassword = repasswordController.text;
    if(_validaEmail(email) && _validaSenha(password, repassword)){
      Database db = await _openBanco();
      Map<String, dynamic> dadosUser = {'email': email, 'password': password};
      int idUser = await db.insert('Usuário', dadosUser);
      print('Id retornado: $idUser');
      setState((){
        status = 'Usuário de ID $idUser cadastrado com sucesso!';
        corResultado = corSucesso;
      });
    }
    else{
      setState(() {
        status;
        corResultado = corErro;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Email',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.purple
              ),
            ),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 5,),
            const Text(
              "Password",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.purple
              )
            ),
            TextField(
              controller: repasswordController,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
            ),
            const SizedBox(height: 50,),
            ElevatedButton(
              onPressed: _salvar,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text('Sign Up', style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ))),
              const SizedBox(height: 8,),
              Text(status, style: TextStyle(
                color: corResultado,
                fontWeight: FontWeight.bold
              ),)
          ],
        ),
      ),
    );
  }
}