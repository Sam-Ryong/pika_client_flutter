import 'package:flutter/material.dart';
import 'package:pika_client_flutter/models/webtoon_detail_model.dart';
import 'package:pika_client_flutter/models/webtoon_episode_model.dart';
import 'package:pika_client_flutter/services/api_service.dart';
import 'package:pika_client_flutter/widgets/episode_widget.dart';

class DetailScreen extends StatefulWidget {
  final String title, thumb, id;
  const DetailScreen({
    super.key,
    required this.title,
    required this.thumb,
    required this.id,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<WebtoonDetailModel> webtoon;
  late Future<List<WebtoonEpisodeModel>> episodes;

  @override
  void initState() {
    super.initState();
    webtoon = ApiService.getToonById(widget.id);
    episodes = ApiService.getLatestEpisodesById(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 24,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: widget.id,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 5,
                            offset: const Offset(10, 10),
                            color: Colors.black.withOpacity(0.7),
                          )
                        ]),
                    width: 250,
                    clipBehavior: Clip.hardEdge,
                    child: Image.network(
                      widget.thumb,
                      headers: const {
                        'User-Agent':
                            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
                        'Referer': 'https://comic.naver.com'
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            FutureBuilder(
              future: webtoon,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.data!.about,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "${snapshot.data!.genre}/${snapshot.data!.age}",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                }
                return const Text("...");
              },
            ),
            const SizedBox(
              height: 20,
            ),
            FutureBuilder(
                future: episodes,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                        ),
                        child: makeList(snapshot),
                      ),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                })
          ],
        ),
      ),
    );
  }

  ListView makeList(AsyncSnapshot<List<WebtoonEpisodeModel>> snapshot) {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return const SizedBox(
          width: 20,
        );
      },
      scrollDirection: Axis.vertical,
      itemCount: snapshot.data!.length,
      itemBuilder: (context, index) {
        var episode = snapshot.data![index];
        return EpisodesWidget(id: episode.id, title: episode.title);
      },
    );
  }
}
