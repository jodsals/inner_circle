import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Debug page to test direct Firestore access
class PostsDebugPage extends StatelessWidget {
  final String communityId;
  final String forumId;

  const PostsDebugPage({
    super.key,
    required this.communityId,
    required this.forumId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts Debug')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('communities')
            .doc(communityId)
            .collection('forums')
            .doc(forumId)
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 8),
                  if (snapshot.error.toString().contains('permission'))
                    const Text(
                      'Firestore Rules Problem!\nBitte deployen Sie die Rules mit:\nfirebase deploy --only firestore:rules',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.orange),
                    ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Lädt Posts aus Firestore...'),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 48),
                  const SizedBox(height: 16),
                  const Text('Keine Posts gefunden'),
                  const SizedBox(height: 8),
                  Text(
                    'Community: $communityId\nForum: $forumId',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      // Test write permission
                      try {
                        await FirebaseFirestore.instance
                            .collection('communities')
                            .doc(communityId)
                            .collection('forums')
                            .doc(forumId)
                            .collection('posts')
                            .add({
                          'title': 'Test Post',
                          'content': 'Test Content',
                          'authorId': 'test',
                          'authorName': 'Test User',
                          'createdAt': FieldValue.serverTimestamp(),
                          'likesCount': 0,
                          'commentsCount': 0,
                          'isEdited': false,
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Test Post erstellt!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Fehler: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text('Test Post erstellen'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data['title'] ?? 'No title'),
                subtitle: Text(data['content'] ?? 'No content'),
                trailing: Text('ID: ${doc.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
