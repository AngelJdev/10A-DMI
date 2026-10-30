import 'package:flutter/material.dart';

import '../widgets/demo_scaffold.dart';

class InfiniteScreen extends StatefulWidget {
  const InfiniteScreen({super.key});
  @override
  State<InfiniteScreen> createState() => _InfiniteScreenState();
}

class _InfiniteScreenState extends State<InfiniteScreen> {
  final controller = ScrollController();
  final images = List.generate(8, (index) => index + 10);
  bool loading = false, refreshing = false;
  int generation = 0;
  @override
  void initState() {
    super.initState();
    controller.addListener(onScroll);
  }

  void onScroll() {
    if (controller.hasClients && controller.position.extentAfter < 500) {
      loadMore();
    }
  }

  Future<void> loadMore() async {
    if (loading || refreshing) return;
    final requestGeneration = generation;
    setState(() => loading = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted || requestGeneration != generation) return;
    setState(() {
      final next = images.last + 1;
      images.addAll(List.generate(8, (index) => next + index));
      loading = false;
    });
  }

  Future<void> refresh() async {
    if (refreshing) return;
    generation++;
    setState(() {
      refreshing = true;
      loading = false;
    });
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      final next = images.last + 1;
      images
        ..clear()
        ..addAll(List.generate(8, (index) => next + index));
      refreshing = false;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DemoScaffold(
    title: 'Scroll infinito',
    child: RefreshIndicator(
      onRefresh: refresh,
      child: ListView.builder(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        itemCount: images.length + 1,
        itemBuilder: (context, index) {
          if (index == images.length) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: loading
                    ? const CircularProgressIndicator()
                    : TextButton(
                        onPressed: loadMore,
                        child: const Text('Cargar más'),
                      ),
              ),
            );
          }
          final id = images[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                FadeInImage(
                  placeholder: const AssetImage('assets/images/loading.gif'),
                  image: NetworkImage(
                    'https://picsum.photos/seed/widgets-$id/700/400',
                  ),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  imageErrorBuilder: (_, _, _) => const SizedBox(
                    height: 220,
                    child: Center(
                      child: Text(
                        'Sin conexión · desliza hacia abajo para actualizar',
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Imagen $id'),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
