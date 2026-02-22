import 'package:atlas/providers/SocialProvider.dart';
import 'package:atlas/widgets/login/Toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final social = Provider.of<SocialProvider>(context, listen: false);
      social.initFriendsListener();
      social.initRequestsListener();
      social.clearSearch();
    });
  }

  void _handleSearch() async {
    final String query = _searchController.text.trim();
    if (query.isEmpty) return;

    final social = Provider.of<SocialProvider>(context, listen: false);
    await social.searchUser(query);

    if (mounted && social.searchedUser == null && !social.isLoading) {
      Toast.show(context, "Utilisateur introuvable ou c'est vous 🔍");
    }
  }

  @override
  Widget build(BuildContext context) {
    final socialProvider = context.watch<SocialProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Communauté", style: GoogleFonts.lilitaOne(fontSize: 24, color: textColor)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: yellowColor,
          labelColor: isDark ? yellowColor : Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: [
            const Tab(text: "MES AMIS"),
            Tab(text: "DEMANDES (${socialProvider.requests.length})"),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _handleSearch(),
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Rechercher un pseudo ou email...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: socialProvider.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : IconButton(icon: const Icon(Icons.send), onPressed: _handleSearch),
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),

          if (socialProvider.searchedUser != null)
            _buildUserPreview(socialProvider.searchedUser!, isDark, textColor),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFriendsList(socialProvider, isDark, textColor),
                _buildRequestsList(socialProvider, isDark, textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserPreview(Map<String, dynamic> user, bool isDark, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? yellowColor.withOpacity(0.1) : yellowColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: yellowColor, width: 1.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.black,
            child: Text(user['pseudo'][0].toUpperCase(), style: TextStyle(color: yellowColor, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['pseudo'], style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                Text(user['email'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await Provider.of<SocialProvider>(context, listen: false).sendFriendRequest(user);
              if (mounted) {
                Toast.show(context, "Demande envoyée ! 🚀");
                _searchController.clear();
                Provider.of<SocialProvider>(context, listen: false).clearSearch();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("AJOUTER"),
          ),
          IconButton(
            onPressed: () => Provider.of<SocialProvider>(context, listen: false).clearSearch(),
            icon: const Icon(Icons.close, size: 20),
          )
        ],
      ),
    );
  }

  Widget _buildFriendsList(SocialProvider social, bool isDark, Color textColor) {
    if (social.friends.isEmpty) return const Center(child: Text("Pas encore d'amis.", style: TextStyle(color: Colors.grey)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: social.friends.length,
      itemBuilder: (context, i) {
        final f = social.friends[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
          ),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: yellowColor, child: Text(f['pseudo'][0], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
            title: Text(f['pseudo'], style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            subtitle: Text(f['email'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.card_giftcard, color: Colors.orange, size: 20),
            ),
            onTap: () => Navigator.pushNamed(context, '/send-points', arguments: f),
          ),
        );
      },
    );
  }

  Widget _buildRequestsList(SocialProvider social, bool isDark, Color textColor) {
    if (social.requests.isEmpty) return const Center(child: Text("Aucune demande.", style: TextStyle(color: Colors.grey)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: social.requests.length,
      itemBuilder: (context, i) {
        final r = social.requests[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.black, child: Icon(Icons.person_add, color: Colors.white, size: 20)),
            title: Text(r['fromPseudo'], style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            subtitle: const Text("veut devenir ton ami", style: TextStyle(fontSize: 11, color: Colors.grey)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                  onPressed: () => social.acceptFriendRequest(r)
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}