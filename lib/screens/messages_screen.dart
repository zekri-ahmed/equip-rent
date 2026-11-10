import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class UserConversation {
  UserConversation({
    required this.id,
    required this.userName,
    required this.itemTitle,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    List<Map<String, dynamic>>? initialMessages,
  }) {
    if (initialMessages != null) {
      messages.addAll(initialMessages);
    }
  }

  final String id;
  final String userName;
  final String itemTitle;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final List<Map<String, dynamic>> messages = [];
}

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<UserConversation> conversations = [];
  UserConversation? selectedConversation;
  final messageController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() => isLoading = true);
    try {
      final rows = await SupabaseService.instance.fetchConversations();
      if (mounted) {
        // Parse Supabase rows into conversation objects if present
        final Map<String, UserConversation> map = {};
        for (final row in rows) {
          final id = '${row['id']}';
          final senderId = '${row['sender_id']}';
          final content = '${row['content'] ?? ''}';
          final created = '${row['created_at'] ?? ''}';

          if (!map.containsKey(senderId)) {
            map[senderId] = UserConversation(
              id: id,
              userName: '\u0645\u0633\u062A\u062E\u062F\u0645 Rento',
              itemTitle: '\u0645\u0639\u062F\u0629 \u0645\u0624\u062C\u0631\u0629',
              lastMessage: content,
              time: created.length > 10 ? created.substring(11, 16) : '\u0627\u0644\u0622\u0646',
              unreadCount: 0,
            );
          }
          map[senderId]!.messages.add({
            'sender': senderId == SupabaseService.instance.currentUserId ? 'me' : 'them',
            'text': content,
            'time': created.length > 10 ? created.substring(11, 16) : '\u0627\u0644\u0622\u0646',
          });
        }

        setState(() {
          conversations = map.values.toList();
          if (conversations.isNotEmpty) {
            selectedConversation = conversations.first;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading conversations: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty || selectedConversation == null) return;

    setState(() {
      selectedConversation!.messages.add({
        'sender': 'me',
        'text': text,
        'time': '\u0627\u0644\u0622\u0646',
      });
      messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 850;

    return Directionality(
        textDirection: Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '\u0627\u0644\u0631\u0633\u0627\u0626\u0644 \u0648\u0627\u0644\u0645\u062D\u0627\u062F\u062B\u0627\u062A',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6200EE),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '\u0645\u062D\u0627\u062F\u062B\u0627\u062A\u0643 \u0627\u0644\u0645\u0628\u0627\u0634\u0631\u0629 \u0645\u0639 \u0645\u0644\u0627\u0643 \u0648\u0645\u0633\u062A\u0623\u062C\u0631\u064A \u0627\u0644\u0645\u0639\u062F\u0627\u062A \u0641\u064A Rento',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            )
          else if (conversations.isEmpty)
            _buildEmptyState()
          else
            SizedBox(
              height: 600,
              child: Card(
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    // Conversations list
                    SizedBox(
                      width: isMobile ? 140 : 300,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: const BorderRadius.only(topRight: Radius.circular(12)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.chat, color: Color(0xFF6200EE)),
                                const SizedBox(width: 8),
                                if (!isMobile)
                                  const Text(
                                    '\u0627\u0644\u0645\u062D\u0627\u062F\u062B\u0627\u062A',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: conversations.length,
                              separatorBuilder: (_, _) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final conv = conversations[index];
                                final isSelected = selectedConversation?.id == conv.id;
                                return Material(
                                  color: isSelected ? const Color(0xFFF0EDFF) : Colors.transparent,
                                  child: ListTile(
                                    selected: isSelected,
                                    selectedTileColor: const Color(0xFFF0EDFF),
                                    onTap: () => setState(() => selectedConversation = conv),
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFF6200EE),
                                      child: Text(
                                        conv.userName.isNotEmpty ? conv.userName[0] : '\u0645',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    title: isMobile
                                        ? null
                                        : Text(
                                            conv.userName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                    subtitle: isMobile
                                        ? null
                                        : Text(
                                            conv.itemTitle,
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 1),

                    // Active Chat Box
                    Expanded(
                      child: selectedConversation == null
                          ? const Center(child: Text('\u0627\u062E\u062A\u0631 \u0645\u062D\u0627\u062F\u062B\u0629 \u0644\u0639\u0631\u0636 \u0627\u0644\u062A\u0641\u0627\u0635\u064A\u0644'))
                          : Column(
                              children: [
                                // Chat header
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  color: Colors.grey.shade50,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: const Color(0xFF6200EE),
                                        child: Text(
                                          selectedConversation!.userName.isNotEmpty
                                              ? selectedConversation!.userName[0]
                                              : '\u0645',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            selectedConversation!.userName,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            selectedConversation!.itemTitle,
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),

                                // Chat messages list
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: selectedConversation!.messages.length,
                                    itemBuilder: (context, index) {
                                      final msg = selectedConversation!.messages[index];
                                      final isMe = msg['sender'] == 'me';

                                      return Align(
                                        alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isMe ? const Color(0xFF6200EE) : Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${msg['text']}',
                                                style: TextStyle(
                                                  color: isMe ? Colors.white : Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${msg['time']}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: isMe ? Colors.white70 : Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Input row
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, -2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: messageController,
                                          decoration: const InputDecoration(
                                            hintText: '\u0627\u0643\u062A\u0628 \u0631\u0633\u0627\u0644\u062A\u0643 \u0647\u0646\u0627...',
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                          ),
                                          onSubmitted: (_) => _sendMessage(),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _sendMessage,
                                        icon: const Icon(Icons.send, color: Color(0xFF6200EE)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0EDFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.forum_outlined,
                size: 54,
                color: Color(0xFF6200EE),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '\u0644\u0627 \u062A\u0648\u062C\u062F \u0645\u062D\u0627\u062F\u062B\u0627\u062A \u062C\u062F\u064A\u062F\u0629 \u062D\u0627\u0644\u064A\u0627\u064B',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '\u0639\u0646\u062F \u0627\u0644\u062A\u0648\u0627\u0635\u0644 \u0627\u0644\u0645\u0628\u0627\u0634\u0631 \u0645\u0639 \u0645\u0644\u0627\u0643 \u0627\u0644\u0645\u0639\u062F\u0627\u062A \u0623\u0648 \u0627\u0633\u062A\u0644\u0627\u0645 \u0637\u0644\u0628\u0627\u062A \u0643\u0631\u0627\u0621\u060C \u0633\u062A\u0638\u0647\u0631 \u0645\u062D\u0627\u062F\u062B\u0627\u062A\u0643 \u0647\u0646\u0627.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadConversations,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('\u062A\u062D\u062F\u064A\u062B \u0627\u0644\u0645\u062D\u0627\u062F\u062B\u0627\u062A'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6200EE),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
