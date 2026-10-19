import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/marketing_model/source.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:pokakbilling/views/Screens/marketing/source/addSourceScreen.dart';
import 'package:pokakbilling/views/Screens/marketing/source/editSourceScreen.dart';

class SourceScreen extends StatelessWidget {
  const SourceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SourceViewmodel>(
      create: (_) {
        final vm = SourceViewmodel();
        // load sources after first frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          vm.fetchSources();
        });
        return vm;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.violetblue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              CupertinoIcons.arrow_left,
              color: AppColors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: false,
          titleSpacing: 0,
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.share_outlined,
                color: AppColors.white,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                'Sources',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: Consumer<SourceViewmodel>(
                builder: (context, vm, child) {
                  return ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: vm,
                            child: const AddSourcePage(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 18,
                    ),
                    label: const Text(
                      'Sources',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      minimumSize: const Size(0, 28),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[100],
        body: Consumer<SourceViewmodel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.errorMessage != null) {
              return Center(child: Text('Error: ${vm.errorMessage}'));
            }
            if (vm.sources.isEmpty) {
              return const Center(child: Text('No sources available'));
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              itemCount: vm.sources.length,
              itemBuilder: (context, index) {
                final source = vm.sources[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SourceCard(
                    source: source,
                    onEdit: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: vm,
                            child: EditSourcePage(source: source),
                          ),
                        ),
                      );
                    },
                    onDelete: () =>
                        _showDeleteConfirmation(context, vm, source),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, SourceViewmodel vm, Source source) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Source'),
          content: Text('Are you sure you want to delete "${source.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: vm.deleteSourceLoading
                  ? null
                  : () {
                      Navigator.of(dialogContext).pop();
                      vm.deleteSource(source.id, context);
                    },
              child: vm.deleteSourceLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// ---------- SourceCard widget (same visual style as LocationScreen card) ----------
class SourceCard extends StatelessWidget {
  final Source source;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SourceCard({
    super.key,
    required this.source,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const double actionAreaWidth = 60.0;
    const double cardHeight = 54.0;

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: cardHeight,
        child: Stack(
          children: [
            // Top border line
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
                              const Icon(Icons.share_outlined,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  source.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
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

                    // Right action area (narrow)
                    Container(
                      width: actionAreaWidth,
                      height: cardHeight,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        border: Border(
                          top: BorderSide(color: Color(0xFF232792), width: 1.0),
                          right: BorderSide(color: Color(0xFF232792)),
                          bottom: BorderSide(color: Color(0xFF232792)),
                        ),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: onEdit,
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.edit_outlined,
                                  size: 18, color: Color(0xFF62748E)),
                            ),
                          ),
                          InkWell(
                            onTap: onDelete,
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.delete_outline,
                                  size: 18, color: Color(0xFF62748E)),
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
      ),
    );
  }
}
