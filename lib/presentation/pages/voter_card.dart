import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:untitled4/data/models/chief_model.dart';

class VoterCard extends StatelessWidget {
  final Voter voter;

  const VoterCard({Key? key, required this.voter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              voter.fullName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'عدد الناخبين: ${voter.phone}',
              style: TextStyle(fontSize: 16),
            ),
            if (voter.cardImage != null && voter.cardImage!.isNotEmpty) ...[
              SizedBox(height: 12),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(title: Text("صورة الناخب")),
                            body: Center(
                              child: PhotoView(
                                imageProvider: NetworkImage(voter.cardImage!),
                                minScale: PhotoViewComputedScale.contained * 0.8,
                                maxScale: PhotoViewComputedScale.covered * 2,
                                initialScale: PhotoViewComputedScale.contained,
                                backgroundDecoration: BoxDecoration(color: Colors.white),
                                loadingBuilder: (context, event) => Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorBuilder: (context, error, stackTrace) => Center(
                                  child: Icon(Icons.error, color: Colors.red, size: 50),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      voter.cardImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(Icons.error, color: Colors.red, size: 50),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}