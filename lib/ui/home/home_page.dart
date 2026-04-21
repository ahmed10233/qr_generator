import 'package:flutter/material.dart';
import 'package:qr_generate/ui/ticket_page/ticket_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        children: [
          Text("CLICK TO GO TO QR"),
          Row(
            mainAxisAlignment: .center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(45),
                ),

                height: 100,
                width: 200,
                child: IconButton(
                  color: Colors.amber,

                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateTicketPage(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.transfer_within_a_station_outlined,
                    size: 80,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
