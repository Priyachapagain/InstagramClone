import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserProfile;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserProfile,
});
  @override
  _ChatScreenState createState() => _ChatScreenState();

}

class _ChatScreenState extends State<ChatScreen>{
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController(); //For auto-scrolling

  ///Get chat Id (user1id_user2id)
  String getChatId(){
    List<String> ids =
        [widget.currentUserId, widget.otherUserId];
    ids.sort();
    return ids.join("_");
  }

  /// Send message
  Future<void> _sendMessage() async {
    if(_messageController.text.trim().isEmpty) return;

    String chatId = getChatId();
    String messageText = _messageController.text.trim();
    _messageController.clear();

    DocumentReference chatRef =
        _firestore.collection('chats').doc(chatId);

    await chatRef.collection('messages').add({
      'text':messageText,
      'senderId': widget.currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await chatRef.set({
      'users': [widget.currentUserId, widget.otherUserId],
      'lastMessage': messageText,
      'lastMessageSender': widget.currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)
    );

    //Scroll to bottom after sending a message
    Future.delayed(const Duration(milliseconds: 100), (){
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context){
    String chatId = getChatId();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.otherUserProfile),
            ),
            const SizedBox(width: 10,),
            Text(widget.otherUserName,
              style: const TextStyle(color: Colors.white),
            ),

          ],
        ),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(child: StreamBuilder(
              stream: _firestore.collection('chats')
              .doc(chatId).collection('messages')
              .orderBy('timestamp', descending: true)
              .snapshots(),
              builder: (context, snapshot){
                if(!snapshot.hasData) return
                    const Center(child: CircularProgressIndicator(),);
                var messages = snapshot.data!.docs;
                return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index){
                      var message = messages[index];
                      bool isMine = message['senderId'] == widget.currentUserId;
                      Timestamp? timestamp = message['timestamp'] as Timestamp?;
                      String formattedTime = timestamp != null
                         ? DateFormat('hh:mm a').format(timestamp.toDate())
                          : '';
                      return Align(
                        alignment: isMine ?
                        Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,

                          ),
                          decoration: BoxDecoration(
                            color: isMine ? Colors.blue :
                                Colors.grey[800],
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(15),
                              topRight: const Radius.circular(15),
                              bottomLeft: isMine ?
                                  const Radius.circular(15) : Radius.zero,
                              bottomRight: isMine ?
                                  Radius.zero : const Radius.circular(15),
                            )
                          ),
                          child: Column(
                            crossAxisAlignment: isMine ? CrossAxisAlignment.end :
                                CrossAxisAlignment.start,
                            children: [
                              Text(message['text'],
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(height: 5,),
                              Text(
                                formattedTime,
                                style: const
                                TextStyle(color: Colors.white70,
                                    fontSize: 12),
                              )
                            ],
                          ),
                        ),
                      );
                    });
              })),

           Padding(
             padding: const EdgeInsets.all(10.0),
             child: Row(
               children: [
                 Expanded(
                   child: Container(
                     decoration: BoxDecoration(
                       color: Colors.grey[900],
                       borderRadius: BorderRadius.circular(25),
                     ),
                     child: TextField(
                       controller: _messageController,
                       style: const TextStyle(color: Colors.white),
                       decoration: const InputDecoration(
                         hintText: "Type a message...",
                         hintStyle: TextStyle(color: Colors.white70),
                         contentPadding:
                         EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                         border: InputBorder.none,
                       ),
                     ),
                   ),
                 ),
                 const SizedBox(width: 10,),
                 GestureDetector(
                   onTap: _sendMessage,
                   child: Container(
                     padding: const EdgeInsets.all(12),
                     decoration: const BoxDecoration(
                       color: Colors.blue,
                       shape: BoxShape.circle,
                     ),
                     child: const Icon(Icons.send,color: Colors.white, size: 24,),
                   ),
                 )
               ],
             ),
           )
        ],
      ),
    );
  }
}