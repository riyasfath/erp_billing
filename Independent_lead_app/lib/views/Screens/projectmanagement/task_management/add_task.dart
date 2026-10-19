import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/member_project_task_model.dart';
import 'package:pokakbilling/viewmodels/project_management/task_management_viewmodel.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/exit_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/buttons/colored_custom_button.dart';
import 'package:pokakbilling/views/commonWidgets/textfields/custom_text.dart';
import 'package:provider/provider.dart';

class AddTask extends StatefulWidget {
  final int projectTeamId;
  final bool isEdit;
  final int? taskId;
  final MemberProjectTaskModel? task;
  const AddTask(
      {super.key,
      required this.projectTeamId,
      required this.isEdit,
      this.taskId,
      this.task});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  late TextEditingController startDateTextController;
  late TextEditingController endDateTextController;
  late TextEditingController taskNameTextController;
  late TextEditingController taskDescriptionTextController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    startDateTextController =
        TextEditingController(text: widget.task?.startDate ?? '');
    endDateTextController =
        TextEditingController(text: widget.task?.endDate ?? '');
    taskNameTextController =
        TextEditingController(text: widget.task?.taskName ?? '');
    taskDescriptionTextController =
        TextEditingController(text: widget.task?.taskDescription ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskManagementProvider =
          Provider.of<TaskManagementViewmodel>(context, listen: false);
      taskManagementProvider.selectStatus(widget.task?.displayStatus ?? '');
    });
  }

  @override
  void dispose() {
    startDateTextController.dispose();
    endDateTextController.dispose();
    taskNameTextController.dispose();
    taskDescriptionTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 150,
                decoration: const BoxDecoration(
                  color: AppColors.violetblue,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: AppBar(
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    title: Text(
                      widget.isEdit ? "Edit Task" : "Add Task",
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 120,
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      color: AppColors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Form(
                        key: formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: taskNameTextController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'required';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Task Name',
                                  hintText: "",
                                  labelStyle: TextStyle(
                                    color: AppColors.violetblue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: taskDescriptionTextController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'required';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  hintText: "",
                                  labelStyle: TextStyle(
                                    color: AppColors.violetblue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: startDateTextController,
                                      decoration: InputDecoration(
                                        label: const CustomText(
                                          text: "Start Date",
                                          isMandatory: false,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 2.0, horizontal: 1.0),
                                        suffixIcon: IconButton(
                                          icon: const Icon(
                                            Icons.calendar_month,
                                            color: AppColors.grey,
                                          ),
                                          onPressed: () => _selectDate(
                                            context,
                                            startDateTextController,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: TextField(
                                      controller: endDateTextController,
                                      decoration: InputDecoration(
                                        label: const CustomText(
                                          text: "End Date",
                                          isMandatory: false,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 2.0, horizontal: 1.0),
                                        suffixIcon: IconButton(
                                          icon: const Icon(
                                            Icons.calendar_month,
                                            color: AppColors.grey,
                                          ),
                                          onPressed: () => _selectDate(
                                            context,
                                            endDateTextController,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Consumer<TaskManagementViewmodel>(
                                builder: (context, provider, child) {
                                  return DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      label: CustomText(
                                        text: 'Status',
                                        isMandatory: false,
                                      ),
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    initialValue: provider.statusList
                                            .contains(provider.selectedStatus)
                                        ? provider.selectedStatus
                                        : null,
                                    items: provider.statusList.map((status) {
                                      return DropdownMenuItem(
                                        value: status,
                                        child: Text(
                                          status,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w400),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (status) {
                                      if (status != null) {
                                        provider.selectStatus(status);
                                      }
                                    },
                                    dropdownColor: AppColors.white,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Consumer<TaskManagementViewmodel>(
                        builder: (context, provider, child) {
                      return ColoredCustomButton(
                        text: widget.isEdit ? "Update" : "Save",
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (widget.isEdit) {
                              await provider.updateTask(
                                widget.projectTeamId,
                                widget.taskId!,
                                taskNameTextController.text,
                                taskDescriptionTextController.text,
                                startDateTextController.text,
                                endDateTextController.text,
                                provider.selectedStatusKey,
                                context,
                              );
                            } else {
                              await provider.createTask(
                                widget.projectTeamId,
                                taskNameTextController.text,
                                taskDescriptionTextController.text,
                                startDateTextController.text,
                                endDateTextController.text,
                                provider.selectedStatusKey,
                                context,
                              );
                            }
                          }
                        },
                        loading: widget.isEdit
                            ? provider.updateTaskLoader
                            : provider.createtaskLoader,
                        formKey: formKey,
                      );
                    }),
                    const SizedBox(height: 20),
                    const ExitCustomButton(
                      text: "Exit",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _selectDate(BuildContext context, fromTextController) async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (pickedDate != null) {
    fromTextController.text = "${pickedDate.toLocal()}".split(' ')[0];
  }
}
