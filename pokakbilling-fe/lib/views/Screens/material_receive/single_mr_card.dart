import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/material_receive_viewmodel.dart';
import 'package:pokakbilling/views/Screens/material_receive/edit/edit_material_receive.dart';
import 'package:pokakbilling/views/Screens/material_receive/view/view_mr.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/action_button.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class SingleMaterialReceiveCard extends StatelessWidget {
  final int index;
  const SingleMaterialReceiveCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final materialProvider = Provider.of<MaterialReceiveViewmodel>(context);
    var materialreceive = materialProvider.materialReceiveList[index];

    return Container(
      height: screenHeight * 0.112,
      width: screenWidth * screenWidth,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 5.0,
          left: 10.0,
          right: 12.0,
          bottom: 5.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("${(index + 1).toString()}."),
                const SizedBox(width: 10),
                Text(materialreceive.receivedDate),
                const Spacer(),
                Text(materialreceive.materialReceiveNumber),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 10),
                const Text("Material Name"),
                const Spacer(),
                Text(materialreceive.supplierName),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ActionButton(
                  text: "VIEW",
                  loading: false,
                  onPressed: () async {
                    await materialProvider
                        .getMaterialReceiveById(materialreceive.mrId);

                    if (materialProvider.singleMaterialReceiveLoading) {
                      const CircularProgressIndicator();
                    } else {
                      if (!context.mounted) return;
                      pushNavigation(context, const ViewMaterialReceive());
                    }
                  },
                  isColored: true,
                ),
                SizedBox(
                  width: screenWidth * 0.03,
                ),
                ActionButton(
                  text: "DELETE",
                  loading: false,
                  onPressed: () {
                    showDeleteDialog(
                      context,
                      "Material Receive",
                      () async {
                        await materialProvider.deleteMaterialReceive(
                          materialreceive.mrId,
                          context,
                        );
                        materialProvider.getAllMaterialReceive();
                      },
                    );
                  },
                  isColored: false,
                ),
                SizedBox(
                  width: screenWidth * 0.03,
                ),
                ActionButton(
                  text: "EDIT",
                  loading: false,
                  onPressed: () async {
                    await materialProvider
                        .getMaterialReceiveById(materialreceive.mrId);

                    if (materialProvider.singleMaterialReceiveLoading) {
                      const CircularProgressIndicator();
                    } else {
                      if (!context.mounted) return;
                      pushNavigation(context,
                          EditMaterialReceive(mrId: materialreceive.mrId));
                    }
                  },
                  isColored: false,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
