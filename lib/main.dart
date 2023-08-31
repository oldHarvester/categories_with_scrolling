import 'package:flutter/material.dart';
import 'package:masonry_grid/masonry_grid.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:test/models/category_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          tabBarTheme: const TabBarTheme(
            indicatorColor: Colors.teal,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.black,
          )),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final itemPosListener = ItemPositionsListener.create();

  final table = CategoryModel.tableByYear;

  late final tabController = TabController(
    length: table.keys.length,
    vsync: this,
  );

  final scrollController = ItemScrollController();

  @override
  void initState() {
    itemPosListener.itemPositions.addListener(() {
      final newCreatedItems = <int>[];
      for (var position in itemPosListener.itemPositions.value) {
        newCreatedItems.add(position.index);
      }
      newCreatedItems.sort();
      if (newCreatedItems.isNotEmpty) {
        var index = newCreatedItems.first;
        if (tabController.index != index && !tabController.indexIsChanging) {
          tabController.animateTo(index);
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Категории'),
      ),
      body: Column(
        children: [
          TabBar(
            onTap: (value) {
              scrollController.scrollTo(
                index: tabController.index,
                duration: const Duration(milliseconds: 200),
              );
            },
            controller: tabController,
            isScrollable: true,
            tabs: List.generate(
              table.keys.length,
              (index) {
                return Tab(
                  text: table.keys.toList()[index].toString(),
                );
              },
            ),
          ),
          Expanded(
            child: ScrollablePositionedList.separated(
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemScrollController: scrollController,
              padding: const EdgeInsets.all(16.0),
              itemPositionsListener: itemPosListener,
              itemCount: table.keys.length,
              itemBuilder: (context, index) {
                final title = table.keys.toList()[index];
                final movies = table.values.toList()[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        title.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    MasonryGrid(
                      column: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: List.generate(movies.length, (index) {
                        final movie = movies[index];
                        return Container(
                          height: 100,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.tealAccent,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Text(movie.name),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
