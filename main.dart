import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Directly linking your Firebase keys inside the code
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBKdjX2DAcgT_yklBZdTe9D6hIbQAiE-vc",
      authDomain: "chatapp-81c13.firebaseapp.com",
      projectId: "chatapp-81c13",
      storageBucket: "chatapp-81c13.firebasestorage.app",
      messagingSenderId: "907954904111",
      appId: "1:907954904111:web:f4245d78b8d46b898fbada",
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Professional Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const FakeLoginScreen(),
    );
  }
}

class FakeLoginScreen extends StatelessWidget {
  const FakeLoginScreen({Key? key}) : super(key: key);

  void _navigateToChat(BuildContext context, String myId, String receiverId, String receiverName) {
    List<String> ids = [myId, receiverId];
    ids.sort();
    String combinedChatId = ids.join("_");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: combinedChatId,
          currentUserId: myId,
          receiverName: receiverName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Test User Profile')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Choose a user profile to log into this device:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              ElevatedButton(
                onPressed: () => _navigateToChat(context, 'user_abc', 'user_xyz', 'Alice Smith'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Log in as: John Doe (Talking to Alice)', style: TextStyle(color: Colors.white)),
              ),
              
              const SizedBox(height: 15),
              
              ElevatedButton(
                onPressed: () => _navigateToChat(context, 'user_xyz', 'user_abc', 'John Doe'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: Colors.green,
                ),
                child: const Text('Log in as: Alice Smith (Talking to John)', style: TextStyle(color: Colors.white)),
              ),
              
              const SizedBox(height: 40),
              const Card(
                color: Colors.amberAccent,
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    '💡 Your live backend is connected! Run your new compilation build inside Codemagic now to download your complete chat application.',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
