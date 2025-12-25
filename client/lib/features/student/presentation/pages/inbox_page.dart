import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  final List<Map<String, String>> _conversations = const [
    {"name": "Prof. Ionescu", "last": "Tema pentru mâine trimisă", "time": "09:12"},
    {"name": "Secretariat", "last": "Orarul pentru luna viitoare", "time": "Ieri"},
    {"name": "Diriginte", "last": "Ședință părinți vineri", "time": "2 zile"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 36, bottom: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF111827)]),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'inbox_title'.tr,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                // optional action icons
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'search'.tr,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (v) {},
              ),
            ),
          ),
          const SizedBox(height: 12),

          // conversations list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final convo = _conversations[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: const Color(0xFF0F172A),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1F2937),
                    child: Text(convo['name']!.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join(),
                        style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(convo['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  subtitle: Text(convo['last']!, style: TextStyle(color: Colors.white.withOpacity(0.7))),
                  trailing: Text(convo['time']!, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                  onTap: () {
                    // open chat screen (placeholder)
                    Get.snackbar('info'.tr, convo['name']!, snackPosition: SnackPosition.BOTTOM);
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: _conversations.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // compose message
          Get.snackbar('info'.tr, 'compose'.tr, snackPosition: SnackPosition.BOTTOM);
        },
        backgroundColor: const Color(0xFF1F2937),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}
