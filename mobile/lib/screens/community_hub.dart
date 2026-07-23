import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../services/api_service.dart';

class CommunityHubScreen extends StatefulWidget {
  const CommunityHubScreen({super.key});

  @override
  State<CommunityHubScreen> createState() => _CommunityHubScreenState();
}

class _CommunityHubScreenState extends State<CommunityHubScreen> {
  List<CommunityPost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      _posts = await apiService.fetchCommunityPosts();
    } catch (e) {
      debugPrint('Error loading posts: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👥 Community Hub'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPosts,
              child: _posts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.forum, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No community posts yet'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        return _buildPostCard(_posts[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: CircleAvatar(
              backgroundColor: _getAuthorColor(post.authorType),
              child: Icon(
                _getAuthorIcon(post.authorType),
                color: Colors.white,
              ),
            ),
            title: Text(
              post.authorName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(post.timeAgo),
            trailing: post.isPinned
                ? const Icon(Icons.push_pin, color: Colors.orange)
                : null,
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(post.content),
              ],
            ),
          ),

          // Image
          if (post.imageUrl != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Tags & Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (post.tags != null)
                  ...post.tags!.map((tag) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(tag),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    );
                  }),
                const Spacer(),
                Icon(Icons.visibility, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${post.views}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAuthorIcon(String authorType) {
    switch (authorType) {
      case 'lgu':
        return Icons.account_balance;
      case 'ndrrmc':
        return Icons.shield;
      case 'barangay':
        return Icons.home;
      default:
        return Icons.person;
    }
  }

  Color _getAuthorColor(String authorType) {
    switch (authorType) {
      case 'lgu':
        return Colors.blue;
      case 'ndrrmc':
        return Colors.red;
      case 'barangay':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
