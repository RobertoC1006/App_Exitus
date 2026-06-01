import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/core/mock/mock_data.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'package:google_fonts/google_fonts.dart';

class InboxMessagesView extends StatefulWidget {
  final User currentUser;
  final VoidCallback? onMessageRead;

  const InboxMessagesView({super.key, required this.currentUser, this.onMessageRead});

  @override
  State<InboxMessagesView> createState() => _InboxMessagesViewState();
}

class _InboxMessagesViewState extends State<InboxMessagesView> {
  final MockDatabase _db = MockDatabase();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showReplyToast(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? LucideIcons.alertCircle : LucideIcons.checkCircle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _openMessageDetails(InboxMessage message) {
    // Marcar como leído
    _db.markMessageAsRead(widget.currentUser.id, message.id);
    if (widget.onMessageRead != null) {
      widget.onMessageRead!();
    }
    setState(() {});

    final replyController = TextEditingController();
    bool isReplying = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            String senderPhoto = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80';
            if (message.sender.contains('Dirección')) {
              senderPhoto = 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=80';
            } else if (message.sender.contains('Julia') || message.sender.contains('Ana')) {
              senderPhoto = 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=80';
            } else if (message.sender.contains('Auxiliar')) {
              senderPhoto = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80';
            } else if (message.sender.contains('Tesorería')) {
              senderPhoto = 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=80';
            } else if (message.sender.contains('Psic.')) {
              senderPhoto = 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=80';
            }

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
                      "LECTURA DE COMUNICADO",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2848),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Remitente y Fecha
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(senderPhoto),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.sender,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D2848),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                message.date,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFF9098A7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Asunto
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        message.subject.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D2848),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Contenido
                    Text(
                      message.content,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2D2D2D),
                        height: 1.45,
                      ),
                    ),
                    const Divider(height: 32, color: Color(0xFFE2E8F0)),

                    // Campo de respuesta rápida
                    const Text(
                      "Respuesta Rápida",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: replyController,
                            enabled: !isReplying,
                            decoration: InputDecoration(
                              hintText: "Responder al remitente...",
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
                          onTap: isReplying
                              ? null
                              : () async {
                                  final text = replyController.text.trim();
                                  if (text.isNotEmpty) {
                                    setModalState(() {
                                      isReplying = true;
                                    });
                                    _showReplyToast("Enviando respuesta...", false);

                                    // Simular envío
                                    await Future.delayed(const Duration(milliseconds: 1000));

                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      _showReplyToast("Respuesta enviada correctamente", false);
                                    }
                                  }
                                },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1D2848),
                              shape: BoxShape.circle,
                            ),
                            child: isReplying
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
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
    final messages = _db.getMessagesForUser(widget.currentUser.id);
    final filtered = messages.where((msg) {
      final query = _searchQuery.toLowerCase();
      return msg.sender.toLowerCase().contains(query) ||
          msg.subject.toLowerCase().contains(query) ||
          msg.snippet.toLowerCase().contains(query) ||
          msg.content.toLowerCase().contains(query);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Buscador superior
          TextFormField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val.trim();
              });
            },
            decoration: InputDecoration(
              hintText: "Buscar mensaje o remitente...",
              prefixIcon: const Icon(LucideIcons.search, size: 16),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x, size: 14),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          // Lista de mensajes
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(LucideIcons.mailOpen, size: 36, color: Color(0xFF94A3B8)),
                        SizedBox(height: 8),
                        Text(
                          "Bandeja de entrada vacía",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final msg = filtered[index];
                      return _buildMessageCard(msg);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(InboxMessage msg) {
    String senderPhoto = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80';
    if (msg.sender.contains('Dirección')) {
      senderPhoto = 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=80';
    } else if (msg.sender.contains('Julia') || msg.sender.contains('Ana')) {
      senderPhoto = 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=80';
    } else if (msg.sender.contains('Auxiliar')) {
      senderPhoto = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80';
    } else if (msg.sender.contains('Tesorería')) {
      senderPhoto = 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=80';
    } else if (msg.sender.contains('Psic.')) {
      senderPhoto = 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=80';
    }

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: msg.unread ? const Color(0xFFEDC620).withValues(alpha: 0.3) : const Color(0xFFE8EAF0),
          width: msg.unread ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _openMessageDetails(msg),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar con badge de no leído
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(senderPhoto),
                  ),
                  if (msg.unread)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEDC620), // Punto dorado de no leído
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Remitente y Fecha
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          msg.sender,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: msg.unread ? FontWeight.bold : FontWeight.w600,
                            color: const Color(0xFF1D2848),
                          ),
                        ),
                        Text(
                          msg.date,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Asunto
                    Text(
                      msg.subject,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: msg.unread ? FontWeight.bold : FontWeight.w500,
                        color: msg.unread ? const Color(0xFF1D2848) : const Color(0xFF555B6E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Recorte
                    Text(
                      msg.snippet,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9098A7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
