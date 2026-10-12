import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/video.dart';
import '../providers/season_provider.dart';
import '../providers/video_feed_provider.dart';

class CommentsSheet extends StatefulWidget {
  final Video video;

  const CommentsSheet({super.key, required this.video});

  static void show(BuildContext context, Video video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CommentsSheet(video: video),
    );
  }

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, String>> _displayComments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final feedProvider = context.read<VideoFeedProvider>();
    final savedComments = await feedProvider.getComments(widget.video.id);

    // Comentarios semilla iniciales para dar vida al video
    final seedComments = [
      {'user': '@carlos_dev', 'text': '¡Increíble video! Muy bien explicado 🔥', 'time': 'hace 2h'},
      {'user': '@maria_flutter', 'text': 'Me encantó la animación y el sonido de temporada 😂👏', 'time': 'hace 1h'},
      {'user': '@alex_tech', 'text': 'Clean Architecture con Providers, justo lo que necesitaba 🚀', 'time': 'hace 30m'},
    ];

    _displayComments.addAll(seedComments);
    for (final text in savedComments) {
      _displayComments.insert(0, {
        'user': '@tú (Usuario)',
        'text': text,
        'time': 'ahora',
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final feedProvider = context.read<VideoFeedProvider>();
    feedProvider.addComment(widget.video, text);

    setState(() {
      _displayComments.insert(0, {
        'user': '@tú (Usuario)',
        'text': text,
        'time': 'ahora',
      });
      _commentController.clear();
    });

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final seasonTheme = context.watch<SeasonProvider>().currentTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65 + bottomInset,
      decoration: BoxDecoration(
        color: const Color(0xFF16161D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: Colors.white12, width: 0.5),
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 20, spreadRadius: 5),
        ],
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        children: [
          // Barra de arrastre superior
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Cabecera de la hoja
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Text(
                  '${_displayComments.length} comentarios',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),

          // Lista interactiva de comentarios
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _displayComments.length,
                    itemBuilder: (context, index) {
                      final item = _displayComments[index];
                      final isCurrentUser = item['user']!.contains('@tú');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: isCurrentUser
                                  ? seasonTheme.primaryColor
                                  : Colors.grey[800],
                              child: Text(
                                item['user']!.substring(1, 2).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item['user']!,
                                        style: TextStyle(
                                          color: isCurrentUser
                                              ? seasonTheme.primaryColor
                                              : Colors.white70,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        item['time']!,
                                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['text']!,
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              seasonTheme.likeIcon,
                              color: Colors.white38,
                              size: 16,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Campo inferior para escribir y enviar comentario
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E26),
              border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: seasonTheme.secondaryColor,
                    child: const Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Añadir comentario...',
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _submitComment(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send_rounded, color: seasonTheme.primaryColor, size: 22),
                    onPressed: _submitComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
