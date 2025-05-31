import 'package:chef_buddy/constants/colors.dart';

import 'package:chef_buddy/widgets/dev_widget.dart';
import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 100,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Smart Chef',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              const Text(
                'Made with ❤️ by',
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 70,
              ),
              LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 750) {
                  return const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DeveloperWidget(
                        name: "Dharmendra Reddy M S",
                        imageUrl: "assets/images/dr.jpg",
                        linkedinUrl: 'https://www.linkedin.com/in/dharmendra-reddy-m-s-8289211b1',
                      ),
                      DeveloperWidget(
                        name: "Sakam Chandra Pavan",
                        imageUrl: "assets/images/pavan.jpg",
                        linkedinUrl:
                            'https://www.linkedin.com/in/chandra-pavan-sakam-462a64254',
                      ),
                      DeveloperWidget(
                        name: "Sarika",
                        imageUrl: "assets/images/sarika.jpg",
                        linkedinUrl:
                            'https://www.linkedin.com/in/sarika-a-b47b03253',
                      ),
                    ],
                  );
                } else {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  );
                }
              }),
              const SizedBox(
                height: 100,
              ),
              Container(
                height: 80,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
