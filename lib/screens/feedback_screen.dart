import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'vishvajeetramanuj95@gmail.com',
      queryParameters: {
        'subject': 'Feedback from Goal Tracker App',
        'body': 'Please enter your feedback here',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch email client';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Feedback')),
      body: Center(
        child: ElevatedButton(
          onPressed: _sendEmail,
          child: const Text('Send Feedback'),
        ),
      ),
    );
  }
}
