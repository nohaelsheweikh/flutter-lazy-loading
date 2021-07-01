import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new HomeState();
}

class HomeState extends State<Home> {
  static int page = 1;
  ScrollController _sc = new ScrollController();
  bool isLoading = false;
  bool refresh = false;
  List users = [];
  final dio = new Dio();
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    this._getMoreData(page);
    super.initState();
    _sc.addListener(() {
      if (_sc.position.pixels ==
          _sc.position.maxScrollExtent) {
        _getMoreData(page);
      }

    });
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lazy Load Large List"),
      ),
      body: Container(
        child: _buildList(),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      key: refreshKey,
      child: ListView.builder(
        itemCount: users.length + 1, // Add one more item for progress indicator
        padding: EdgeInsets.symmetric(vertical: 8.0),
        itemBuilder: (BuildContext context, int index) {
          if (index == users.length) {
            return _buildProgressIndicator();
          } else {
            return new ListTile(
              leading: CircleAvatar(
                radius: 30.0,
                backgroundImage: NetworkImage(
                  users[index]['picture']['large'],
                ),
              ),
              title: Text((users[index]['name']['first'])),
              subtitle: Text((users[index]['email'])),
            );
          }
        },
        controller: _sc,
      ),
      onRefresh: refreshList,
    );
  }

  void _getMoreData(int index) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      print(index);
      var url = "https://randomuser.me/api/?page=" +
          index.toString() +
          "&results=20&seed=abc";
      print(url);
      final response = await dio.get(url);
      List tList = [];
      for (int i = 0; i < response.data['results'].length; i++) {
        tList.add(response.data['results'][i]);
      }

      setState(() {
        isLoading = false;
        users.addAll(tList);
        page++;
      });
    }
  }

  Future<Null> refreshList() async {
    print('refresh');
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      var url = "https://randomuser.me/api/?page=1"
          "&results=20&seed=abc";
      print(url);
      final response = await dio.get(url);
      List tList = [];
      for (int i = 0; i < response.data['results'].length; i++) {
        tList.add(response.data['results'][i]);
      }

      setState(() {
        isLoading = false;
        users = tList;
        page = 2;
      });


      return null;
    }
  }
  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }


}

