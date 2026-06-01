import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialFeedView extends StatefulWidget {
  final User currentUser;

  const SocialFeedView({super.key, required this.currentUser});

  @override
  State<SocialFeedView> createState() => _SocialFeedViewState();
}

class _SocialFeedViewState extends State<SocialFeedView> {
  final MockDatabase _db = MockDatabase();
  late List<SocialPost> _posts;

  @override
  void initState() {
    super.initState();
    _posts = _db.getSocialPosts();
  }

  void _refresh() {
    setState(() {
      _posts = _db.getSocialPosts();
    });
  }

  void _showCommentsDrawer(SocialPost post) {
    final commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle visual
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "COMENTARIOS (${post.comments.length})",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2848),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Lista de comentarios
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.35,
                      ),
                      child: post.comments.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Text(
                                  "Aún no hay comentarios. ¡Sé el primero!",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF64748B),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: post.comments.length,
                              separatorBuilder: (context, index) => const Divider(height: 16, color: Color(0xFFF1F5F9)),
                              itemBuilder: (context, index) {
                                final comment = post.comments[index];
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundImage: NetworkImage(comment.avatar),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment.author,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1D2848),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            comment.text,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF2D2D2D),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),

                    const Divider(height: 24, color: Color(0xFFE2E8F0)),

                    // Campo de Texto de Comentario
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: commentController,
                            decoration: InputDecoration(
                              hintText: "Escribe un comentario...",
                              filled: true,
                              fillColor: const Color(0xFFF5F6F9),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            final text = commentController.text.trim();
                            if (text.isNotEmpty) {
                              final newComment = SocialComment(
                                author: widget.currentUser.fullName,
                                avatar: widget.currentUser.avatarUrl,
                                text: text,
                              );
                              _db.addSocialComment(post.id, newComment);
                              setModalState(() {
                                commentController.clear();
                              });
                              _refresh();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1D2848),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.send,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return _buildPostCard(post);
      },
    );
  }

  Widget _buildPostCard(SocialPost post) {
    // Determinar reacción activa
    String activeType = 'none';
    String activeEmoji = '👍';
    post.userReactions.forEach((key, val) {
      if (val) {
        activeType = key;
        if (key == 'likes') activeEmoji = '👍';
        if (key == 'loves') activeEmoji = '❤️';
        if (key == 'bravos') activeEmoji = '👏';
        if (key == 'insights') activeEmoji = '💡';
        if (key == 'haha') activeEmoji = '😂';
        if (key == 'sad') activeEmoji = '😢';
      }
    });

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE8EAF0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fila Remitente / Publicador
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(post.avatar),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.publisher,
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1D2848),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            post.time,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF9098A7),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(LucideIcons.globe, size: 10, color: Color(0xFF9098A7)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Badge Sparkle Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEDC620).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.sparkles, color: Color(0xFFE6A817), size: 10),
                      const SizedBox(width: 4),
                      Text(
                        post.tag,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE6A817),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Contenido del Post
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF2D2D2D),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Imagen del Post (si existe)
            if (post.img != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.img!,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Contadores de Reacciones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildReactionCounters(post),
                  ],
                ),
                GestureDetector(
                  onTap: () => _showCommentsDrawer(post),
                  child: Text(
                    "${post.comments.length} comentarios",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: Color(0xFFF0F2F5)),

            // Fila de Acciones (Reaccionar y Comentar)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Tap simple: toggle Like
                      _db.toggleReaction(post.id, 'likes');
                      _refresh();
                    },
                    onLongPressStart: (details) {
                      _showReactionsPopup(context, details.globalPosition, post);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: activeType != 'none'
                            ? const Color(0xFFEDC620).withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            activeType != 'none' ? activeEmoji : '👍',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            activeType != 'none'
                                ? _getReactionLabel(activeType)
                                : "Reaccionar",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: activeType != 'none'
                                  ? const Color(0xFF1D2848)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _showCommentsDrawer(post),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(LucideIcons.messageSquare, size: 14, color: Color(0xFF64748B)),
                          SizedBox(width: 6),
                          Text(
                            "Comentar",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionCounters(SocialPost post) {
    int total = post.likes + post.loves + post.bravos + post.insights + post.haha + post.sad;
    if (total == 0) return const SizedBox.shrink();

    List<String> emojis = [];
    if (post.likes > 0) emojis.add('👍');
    if (post.loves > 0) emojis.add('❤️');
    if (post.bravos > 0) emojis.add('👏');
    if (post.insights > 0) emojis.add('💡');
    if (post.haha > 0) emojis.add('😂');
    if (post.sad > 0) emojis.add('😢');

    // Tomar máximo 3 distintos para el resumen visual
    List<Widget> children = [];
    int limit = emojis.length.clamp(0, 3);
    for (int i = 0; i < limit; i++) {
      children.add(
        Positioned(
          left: i * 10.0,
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(emojis[i], style: const TextStyle(fontSize: 10)),
          ),
        ),
      );
    }

    return SizedBox(
      width: 32 + (limit * 10.0),
      height: 18,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ...children,
          Positioned(
            left: limit * 12.0,
            top: 2,
            child: Text(
              "$total",
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getReactionLabel(String type) {
    if (type == 'likes') return 'Me Gusta';
    if (type == 'loves') return 'Me Encanta';
    if (type == 'bravos') return 'Excelente';
    if (type == 'insights') return 'Interesante';
    if (type == 'haha') return 'Me Divierte';
    if (type == 'sad') return 'Me Entristece';
    return '';
  }

  void _showReactionsPopup(BuildContext context, Offset globalPos, SocialPost post) {
    final overlayState = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Cerrar al tocar fuera
            GestureDetector(
              onTap: () {
                entry.remove();
              },
              behavior: HitTestBehavior.translucent,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            // Popup de Emojis
            Positioned(
              left: (globalPos.dx - 110).clamp(16.0, MediaQuery.of(context).size.width - 240.0),
              top: globalPos.dy - 65,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1D2848).withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildEmojiReactItem('👍', 'likes', post, entry),
                      _buildEmojiReactItem('❤️', 'loves', post, entry),
                      _buildEmojiReactItem('👏', 'bravos', post, entry),
                      _buildEmojiReactItem('💡', 'insights', post, entry),
                      _buildEmojiReactItem('😂', 'haha', post, entry),
                      _buildEmojiReactItem('😢', 'sad', post, entry),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlayState.insert(entry);
  }

  Widget _buildEmojiReactItem(String emoji, String type, SocialPost post, OverlayEntry entry) {
    return GestureDetector(
      onTap: () {
        _db.toggleReaction(post.id, type);
        entry.remove();
        _refresh();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 150),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
