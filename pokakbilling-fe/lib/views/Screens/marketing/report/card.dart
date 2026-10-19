import 'package:flutter/material.dart';

/// Responsive Source Card that matches your Figma look (gradient left,
/// white right action area with rounded corners).
class SourceCard extends StatelessWidget {
  final String title;
  final IconData leadingIcon;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SourceCard({
    super.key,
    required this.title,
    required this.leadingIcon,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const double actionAreaWidth = 68.0;
    const double cardHeight = 54.0;

    return SizedBox(
      height: cardHeight,
      child: Stack(
        children: [
          // 🔹 Reduced top line
          Positioned(
            top: 0,
            left: 8,
            right: 8,
            child: Container(
              height: 1.0,
              color: const Color(0xFF232792),
            ),
          ),

          LayoutBuilder(
            builder: (context, constraints) {
              final leftWidth = (constraints.maxWidth - actionAreaWidth)
                  .clamp(0.0, constraints.maxWidth);

              return Row(
                children: [
                  // Left gradient section
                  SizedBox(
                    width: leftWidth,
                    height: cardHeight,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                        topRight: Radius.circular(44),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF232792), Color(0xFF141BE4)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(leadingIcon, color: Colors.white, size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Right action area
                  Container(
                    width: actionAreaWidth,
                    height: cardHeight,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: Color(0xFF232792),
                          width: 1.0,
                        ),
                        right: BorderSide(color: Color(0xFF232792)),
                        bottom: BorderSide(color: Color(0xFF232792)),
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: onEdit,
                          child: const Icon(
                            Icons.edit,
                            size: 18,
                            color: Color(0xFF62748E), // 🔹 new color
                          ),
                        ),
                        GestureDetector(
                          onTap: onDelete,
                          child: const Icon(
                            Icons.delete,
                            size: 18,
                            color: Color(0xFF62748E), // 🔹 new color
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Example page with hardcoded data demonstrating the responsive SourceCard
class SourceListPage extends StatelessWidget {
  const SourceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Hardcoded sample entries
    final sources = [
      "LinkedIn",
      "Website",
      "Instagram",
      "Facebook",
      "Justdial",
      "Indeed",
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF232792),
        title: const Text("Sources"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.separated(
            itemCount: sources.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return SourceCard(
                title: sources[index],
                leadingIcon: Icons.share, // sample icon
                onEdit: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Edit ${sources[index]}')),
                ),
                onDelete: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Delete ${sources[index]}')),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
