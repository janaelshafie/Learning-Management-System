import 'package:flutter/material.dart';
import '../../services/api_services.dart';

class StudentMessagingScreen extends StatefulWidget {
  final int userId;
  final int studentId;

  const StudentMessagingScreen({
    super.key,
    required this.userId,
    required this.studentId,
  });

  @override
  State<StudentMessagingScreen> createState() => _StudentMessagingScreenState();
}

class _StudentMessagingScreenState extends State<StudentMessagingScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;

  List<Map<String, dynamic>> _recipients = [];
  List<Map<String, dynamic>> _inboxMessages = [];
  List<Map<String, dynamic>> _sentMessages = [];
  bool _isLoadingRecipients = true;
  bool _isLoadingInbox = true;
  bool _isLoadingSent = true;
  int _unreadCount = 0;

  int? _selectedRecipientId;
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRecipients();
    _loadInbox();
    _loadSentMessages();

    _tabController.addListener(() {
      if (_tabController.index == 0) {
        _loadInbox();
      } else if (_tabController.index == 1) {
        _loadSentMessages();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipients() async {
    if (!mounted) return;
    setState(() {
      _isLoadingRecipients = true;
    });

    try {
      final response = await _apiService.getStudentRecipients(widget.studentId);
      if (!mounted) return;
      if (response['status'] == 'success') {
        setState(() {
          _recipients = List<Map<String, dynamic>>.from(
            response['recipients'] ?? [],
          );
          _isLoadingRecipients = false;
        });
      } else {
        setState(() {
          _isLoadingRecipients = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Error loading recipients'),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingRecipients = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _loadInbox() async {
    if (!mounted) return;
    setState(() {
      _isLoadingInbox = true;
    });

    try {
      final response = await _apiService.getInbox(widget.userId);
      if (!mounted) return;
      if (response['status'] == 'success') {
        setState(() {
          _inboxMessages = List<Map<String, dynamic>>.from(
            response['messages'] ?? [],
          );
          _unreadCount = response['unreadCount'] ?? 0;
          _isLoadingInbox = false;
        });
      } else {
        setState(() {
          _isLoadingInbox = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingInbox = false;
      });
    }
  }

  Future<void> _loadSentMessages() async {
    if (!mounted) return;
    setState(() {
      _isLoadingSent = true;
    });

    try {
      final response = await _apiService.getSentMessages(widget.userId);
      if (!mounted) return;
      if (response['status'] == 'success') {
        setState(() {
          _sentMessages = List<Map<String, dynamic>>.from(
            response['messages'] ?? [],
          );
          _isLoadingSent = false;
        });
      } else {
        setState(() {
          _isLoadingSent = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingSent = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_selectedRecipientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a recipient')),
      );
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a message')));
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final response = await _apiService.sendMessage(
        widget.userId,
        _selectedRecipientId!,
        _messageController.text.trim(),
      );

      if (!mounted) return;
      if (response['status'] == 'success') {
        _messageController.clear();
        _loadSentMessages();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Error sending message'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _markAsRead(int messageId) async {
    try {
      await _apiService.markMessageAsRead(messageId);
      _loadInbox();
    } catch (e) {
      // Silently fail - not critical
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Inbox'),
                  if (_unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Sent'),
            const Tab(text: 'Compose'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildInboxTab(), _buildSentTab(), _buildComposeTab()],
      ),
    );
  }

  Widget _buildInboxTab() {
    if (_isLoadingInbox) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_inboxMessages.isEmpty) {
      return const Center(child: Text('No messages in inbox'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _inboxMessages.length,
      itemBuilder: (context, index) {
        final message = _inboxMessages[index];
        final isRead = message['isRead'] ?? false;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: isRead ? null : Colors.blue.shade50,
          child: ListTile(
            leading: CircleAvatar(
              child: Text((message['senderName'] ?? 'U')[0].toUpperCase()),
            ),
            title: Text(
              message['senderName'] ?? 'Unknown',
              style: TextStyle(
                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message['content'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  message['sentAt'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: !isRead
                ? const Icon(Icons.circle, size: 12, color: Colors.blue)
                : null,
            onTap: () {
              _showMessageDialog(message, isSender: false);
              if (!isRead) {
                _markAsRead(message['messageId']);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildSentTab() {
    if (_isLoadingSent) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sentMessages.isEmpty) {
      return const Center(child: Text('No sent messages'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _sentMessages.length,
      itemBuilder: (context, index) {
        final message = _sentMessages[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              child: Text((message['recipientName'] ?? 'U')[0].toUpperCase()),
            ),
            title: Text(message['recipientName'] ?? 'Unknown'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message['content'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      message['sentAt'] ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (message['isRead'] == true) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.check, size: 16, color: Colors.green[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Read',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            onTap: () {
              _showMessageDialog(message, isSender: true);
            },
          ),
        );
      },
    );
  }

  Widget _buildComposeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Select Recipient',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_isLoadingRecipients)
            const Center(child: CircularProgressIndicator())
          else if (_recipients.isEmpty)
            const Text('No recipients available')
          else
            DropdownButtonFormField<int>(
              value: _selectedRecipientId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Recipient',
              ),
              items: _recipients.map((recipient) {
                final userId = recipient['userId'] as int;
                final name = recipient['name'] ?? 'Unknown';
                final type = recipient['type'] ?? '';
                final courseCode = recipient['courseCode'] ?? '';
                final courseName = recipient['courseName'] ?? '';

                String displayName = '$name ($type)';
                if (courseCode.isNotEmpty) {
                  displayName += ' - $courseCode: $courseName';
                }

                return DropdownMenuItem<int>(
                  value: userId,
                  child: Text(displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRecipientId = value;
                });
              },
            ),
          const SizedBox(height: 24),
          const Text(
            'Message',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            maxLines: 10,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your message...',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSending ? null : _sendMessage,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF1E3A8A),
            ),
            child: _isSending
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Send Message',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }

  void _showMessageDialog(
    Map<String, dynamic> message, {
    required bool isSender,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isSender ? 'Sent Message' : 'Received Message'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'From: ${isSender ? 'You' : message['senderName'] ?? 'Unknown'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'To: ${isSender ? message['recipientName'] ?? 'Unknown' : 'You'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(message['content'] ?? ''),
              const SizedBox(height: 16),
              Text(
                'Sent: ${message['sentAt'] ?? ''}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              if (message['readAt'] != null)
                Text(
                  'Read: ${message['readAt']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
