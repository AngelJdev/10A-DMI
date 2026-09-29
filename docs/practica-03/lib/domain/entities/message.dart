enum FromWho { me, hers }

class Message {
  const Message({
    required this.text,
    required this.fromWho,
    required this.sentAt,
    this.imageUrl,
    this.isLoading = false,
  });

  final String text;
  final FromWho fromWho;
  final String? imageUrl;
  final DateTime sentAt;
  final bool isLoading;
}
