import 'package:flutter/material.dart';
import 'package:qr_generate/ui/home/home_page.dart';
import 'package:qr_generate/ui/ticket_page/ticket_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: .center,
//         children: [
//           Container(
//             color: Colors.amber,
//             height: 50,
//             child: IconButton(
//               color: Colors.amber,

//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => CreateTicketPage()),
//                 );
//               },
//               icon: Icon(Icons.transit_enterexit),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
