// import 'package:flutter/material.dart';
// import 'package:futurex_app/providers/comment_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';

// class ReplyScreen extends StatelessWidget {
//   final int commentId;

//   const ReplyScreen({required this.commentId, super.key});

//   Future<int> _getParentId() async {
//     // Retrieve parentId from SharedPreferences
//     final prefs = await SharedPreferences.getInstance();
//     final parentId = prefs.getInt('parentId');

//     if (parentId == null) {
//       throw Exception("Parent ID not found. Please log in again.");
//     }
//     return parentId;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Replies")),
//       body: ChangeNotifierProvider(
//         create: (_) => CommentProvider()..fetchReplies(commentId),
//         child: Consumer<CommentProvider>(
//           builder: (context, replyProvider, child) {
//             return Column(
//               children: [
//                 Expanded(
//                   child: replyProvider.isLoading
//                       ? const Center(child: CircularProgressIndicator())
//                       : ListView.builder(
//                           itemCount: replyProvider.replies.length,
//                           itemBuilder: (context, index) {
//                             final reply = replyProvider.replies[index];
//                             return ListTile(
//                               title: Text(reply.reply),
//                               subtitle: Text("By Admin ${reply.adminId}"),
//                             );
//                           },
//                         ),
//                 ),
//                 // Add reply input
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           decoration: const InputDecoration(hintText: "Add a reply..."),
//                           onSubmitted: (value) async {
//                             if (value.isNotEmpty) {
//                               try {
//                                 // Retrieve parentId and use it as adminId
//                                 final adminId = await _getParentId();
//                                 replyProvider.addReply(
//                                   commentId,
//                                   adminId.toString(), // Pass adminId (parentId) as String
//                                   value, // Pass the reply text
//                                 );
//                               } catch (e) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(content: Text(e.toString())),
//                                 );
//                               }
//                             }
//                           },
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.send),
//                         onPressed: () {}, // Implement reply adding logic
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
