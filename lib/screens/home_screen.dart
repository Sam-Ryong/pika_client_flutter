import 'package:flutter/material.dart';
import 'package:pika_client_flutter/models/webtoon_model.dart';
import 'package:pika_client_flutter/services/api_service.dart';
import 'package:pika_client_flutter/widgets/webtoon_widget.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final Future<List<WebtoonModel>> webtoons = ApiService.getTodaysToons();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        title: const Text(
          "어늘의 웹툰",
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
      body: FutureBuilder(
        future: webtoons,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: makeList(snapshot),
                )
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

ListView makeList(AsyncSnapshot<List<WebtoonModel>> snapshot) {
  return ListView.separated(
    separatorBuilder: (context, index) {
      return const SizedBox(
        width: 20,
      );
    },
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    scrollDirection: Axis.horizontal,
    itemCount: snapshot.data!.length,
    itemBuilder: (context, index) {
      var webtoon = snapshot.data![index];
      return Webtoon(
          title: webtoon.title, thumb: webtoon.thumb, id: webtoon.id);
    },
  );
}
