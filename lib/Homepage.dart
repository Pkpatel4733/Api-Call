import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import "package:http/http.dart" as http;
import 'dart:convert';
import 'package:timeago/timeago.dart' as timeago;

Map mapresponce= mapresponce ;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List Posts = [];
  Future apicall() async {
    final url = Uri.parse('https://api.hive.blog/');
    final response = await http.post(
      url,
      headers: {
        'accept': 'application/json, text/plain, */*',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        "id": 1,
        "jsonrpc": "2.0",
        "method": "bridge.get_ranked_posts",
        "params": {"sort": "trending", "tag": "", "observer": "hive.blog"},
      }),
    );
    if (response.statusCode == 200) {
      mapresponce = json.decode(response.body);
      setState(() {
        Posts = mapresponce['result'];
      });
    }
  }

  @override
  void initState() {
    apicall();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts',style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white
        ),),
        backgroundColor: Colors.blueAccent,
      ),
      body: Posts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: Posts.length,
        itemBuilder: (context, index) {
          final post = Posts[index];
          final postTime = DateTime.parse(post['created']);
          final relativeTime = timeago.format(postTime);

          return Card(
            shadowColor: Colors.blue[100],
            elevation:10,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          post['json_metadata']['image'] != null &&
                              post['json_metadata']['image']
                                  .isNotEmpty
                              ? post['json_metadata']['image'][0]
                              : 'https://via.placeholder.com/150',
                        ),
                        radius: 30,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 10),
                            Text(
                              "${post['author']} (${post['author_reputation']})",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "in ${post['community_title']} • $relativeTime",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Divider(
                    height:10,
                    color: Colors.grey,
                    thickness: 1,
                    indent : 5,
                    endIndent : 5,
                  ),
                  SizedBox(height: 5),
                  Text(
                    post['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                     Container(

                      child: Text(
                        post['body']
                            .toString()
                            .replaceAll(RegExp(r'\n'), ' ')
                            .substring(0, 150) + '...',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),

                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.thumb_up_off_alt, size: 18, color: Colors.pink),
                          SizedBox(width: 5),
                          Text(post['net_votes'].toString()),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.insert_comment_outlined, size: 18, color: Colors.blueAccent),
                          SizedBox(width: 5),
                          Text(post['children'].toString()),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.attach_money_outlined,
                              size: 18, color: Colors.green),
                          SizedBox(width: 1),
                          Text("${post['pending_payout_value']}"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
