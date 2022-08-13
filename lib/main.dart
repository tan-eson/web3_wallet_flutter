import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:web3_wallet_flutter/constants/secure_storage_keys.dart';
import 'package:web3_wallet_flutter/model/wallet_private_key.dart';
import 'package:web3_wallet_flutter/screens/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(
    ChangeNotifierProvider(
      create: (context) => PrivateKey(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // attempt to get stored key from persistent storage on launch
  void getKeyFromStorage() {
    const storage = FlutterSecureStorage();
    storage.read(key: SecureStorage.privateKey).then(
      (value) {
        if (value != null) {
          context.read<PrivateKey>().setPrivateKey(value);
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getKeyFromStorage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        primarySwatch: Colors.green,
        fontFamily: GoogleFonts.montserrat().fontFamily,
      ),
      home: const ScreenWrapper(),
    );
  }
}
