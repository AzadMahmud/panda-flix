import 'package:flutter/material.dart';

class ReviewPage extends StatefulWidget {
  final String movieTitle;

  ReviewPage({required this.movieTitle});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Write a Review'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review for ${widget.movieTitle}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber),
            ),
            SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _reviewController,
                maxLines: null,
                expands: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Write your review here...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, null),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _reviewController.text),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
