import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // init hive db
  await Hive.initFlutter();
  await Hive.openBox("people");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Application Ios',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showAuthor = false;
  bool loading = false;
  final TextEditingController nameTextController = TextEditingController();
  final TextEditingController postNameTextController = TextEditingController();

  @override
  Widget build(BuildContext context){
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                if (orientation == Orientation.portrait) ClipPath(
                  clipper: MyCustomClipper(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.35,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            InkWell(
                              onLongPress: (){
                                setState((){
                                  showAuthor = true;
                                });
                              },
                              child: Image.asset("images/undraw_happy_music_g6wc.png",
                                height:  MediaQuery.of(context).size.height * 0.20,
                                width:  MediaQuery.of(context).size.height * 0.20,
                              ),
                            ),
                            if (showAuthor) Text("Masuaku Tenda Osée",
                              style: Theme.of(context).textTheme.headline6.apply(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(143, 148, 251, .3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey[100])),
                              ),
                              child: TextField(
                                controller: nameTextController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Nom*",
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: TextField(
                                controller: postNameTextController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Post-Nom",
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      FlatButton(
                        onPressed: (){
                          if (nameTextController.text.trim().isEmpty){
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Vous devez indiquez un nom",
                                      style: Theme.of(context).textTheme.headline6,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 10.0),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: FlatButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text("OK"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                            return;
                          }
                          if (loading) return;
                          setState((){
                            loading = true;
                          });
                          Future.delayed(Duration(seconds: 3), () {
                            final Box box = Hive.box("people");
                            final Map<String, dynamic> person = {
                              "name": nameTextController.text,
                              "postName": postNameTextController.text,
                            };
                            box.add(person);
                            setState((){
                              loading = false;
                            });
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PersonList(),
                              ),
                            );
                            nameTextController.clear();
                            postNameTextController.clear();
                          });
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                Color.fromRGBO(143, 148, 251, 1),
                                Color.fromRGBO(143, 148, 251, .6),
                              ],
                            ),
                          ),
                          child: Stack(
                            // fit: StackFit.expand,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text("Soumettre", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,)),
                              ),
                              if (loading) Positioned(
                                left: 10.0,
                                child: SpinKitChasingDots(
                                  color: Colors.white,
                                  size: 40.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 70),
                      FlatButton(
                        onPressed: (){
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PersonList(),
                            ),
                          );
                        },
                        child: Text("Liste des enregistrements", style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1), fontWeight: FontWeight.bold,), ),
                      ),
                    ],
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

class MyCustomClipper extends CustomClipper<Path> {
  @override
  getClip(Size size){
    final Path path = Path();

    path.lineTo(0.0, size.height);

    final firstEndPoint = Offset(size.width * .5, size.height - 30.0);
    final firstControlPoint = Offset(size.width * .25, size.height - 50.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    final secondEndPoint = Offset(size.width, size.height - 80.0);
    final secondControlPoint = Offset(size.width * .75, size.height - 10.0);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => true;
}

class PersonList extends StatefulWidget {
  @override
  _PersonListState createState() => _PersonListState();
}

class _PersonListState extends State<PersonList> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Liste"),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box("people").listenable(),
        builder: (BuildContext context, Box box, Widget child) {
          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index){
              final Map<dynamic, dynamic> data = box.values.toList()[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 10.0,
                ),
                child: Material(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 10.0,
                    ),
                    child: Text("${index+1}. ${data['name']} ${data['postName']}"),
                  ),
                ),
              );
            }
          );
        }
      ),
    );
  }
}