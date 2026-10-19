// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/navigations.dart';
// import 'package:pokakbilling/models/data-models/member_project_task_model.dart';
// import 'package:pokakbilling/models/data-models/teamMember_model.dart';
// import 'package:pokakbilling/models/services/team_member_services.dart';
// import 'package:pokakbilling/views/Screens/projectmanagement/team_members/create_TM_Main.dart';
// import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
// import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

// class TeamMemberViewmodel extends ChangeNotifier {
//   String selectedRoleStatus = "";
//   String selectedRoleStatusKey = "";
//   bool addTeamLoader = false;
//   bool getTeamMemberLoader = false;
//   bool singleTeamMemberLoading = false;
//   bool deleteTeamMemberLoading = false;
//   bool taskByIdLoading = false;
//   bool editLoading = false;
//   var teamMemberList = <TeamMemberModel>[];
//   var singleTeamMemberList = <TeamMemberModel>[];
//   var taskList = <MemberProjectTaskModel>[];

//   TeamMemberViewmodel() {
//     getAllTeamMembers();
//   }

//   void setSelectedRoleStatus(String? status) {
//     selectedRoleStatus = status ?? "";
//     notifyListeners();
//   }

//   var roleStatusList = [
//     "Full Stack Developer",
//     "Frontend Developer",
//     "Backend Developer",
//     "UI/UX Designer",
//     "Project Manager",
//     "App Developer",
//     "Digital marketing",
//     "Tester",
//   ];

//   void selectRoleStatus(String teamMember) {
//     selectedRoleStatus = teamMember;
//     switch (teamMember) {
//       case "Full Stack Developer":
//         selectedRoleStatusKey = "full_stack_developer";
//         break;
//       case "Frontend Developer":
//         selectedRoleStatusKey = "frontend_developer";
//         break;
//       case "Backend Developer":
//         selectedRoleStatusKey = "backend_developer";
//         break;
//       case "UI/UX Designer":
//         selectedRoleStatusKey = "ui_ux_designer";
//         break;
//       case "Project Manager":
//         selectedRoleStatusKey = "project_manager";
//         break;
//       case "App Developer":
//         selectedRoleStatusKey = "app_developer";
//       case "Digital marketing":
//         selectedRoleStatusKey = "digital_marketing";
//       case "Tester":
//         selectedRoleStatusKey = "tester";
//         break;
//       default:
//         selectedRoleStatusKey = "";
//     }
//     notifyListeners();
//   }

//   Future<void> createTeamMember(
//     name,
//     role,
//     emailId,
//     phoneNumber,
//     BuildContext context,
//   ) async {
//     try {
//       addTeamLoader = true;
//       notifyListeners();
//       String? response = await TeamMemberServices.createTeamMember(
//         name,
//         role,
//         emailId,
//         phoneNumber,
//       );

//       if (response == null) {
//         if (!context.mounted) return;
//         showSuccessMessage(
//           context,
//           "Team Member Created Successfully!",
//         );
//         getAllTeamMembers();
//         pushNavigation(context, const CreateTeamMemberMain());
//       } else {
//         if (!context.mounted) return;
//         showOverlayError(context, response);
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       addTeamLoader = false;
//       notifyListeners();
//     }
//   }

//   Future<void> getAllTeamMembers() async {
//     try {
//       getTeamMemberLoader = true;
//       notifyListeners();
//       List<TeamMemberModel> teamMemberItems =
//           await TeamMemberServices.getTeamMembers();

//       if (teamMemberItems.isNotEmpty) {
//         teamMemberList = teamMemberItems;
//       } else {
//         teamMemberList.clear();
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       getTeamMemberLoader = false;
//       notifyListeners();
//     }
//   }

//   Future<void> getTeamMemberById(teamMemberId) async {
//     try {
//       singleTeamMemberLoading = true;
//       notifyListeners();
//       List<TeamMemberModel> customerItems =
//           await TeamMemberServices.getTeamMemberById(teamMemberId);

//       if (customerItems.isNotEmpty) {
//         singleTeamMemberList = customerItems;
//       } else {
//         singleTeamMemberList.clear();
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       singleTeamMemberLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> deleteMember(teamMemberId, BuildContext context) async {
//     try {
//       deleteTeamMemberLoading = true;
//       notifyListeners();
//       String? response =
//           await TeamMemberServices.deleteTeamMember(teamMemberId);

//       if (response == null) {
//         if (!context.mounted) return;
//         showSuccessMessage(
//           context,
//           "Team Member Deleted Successfully!",
//         );
//         getAllTeamMembers();
//         pushNavigation(context, const CreateTeamMemberMain());
//       } else {
//         if (!context.mounted) return;
//         showOverlayError(context, response);
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       deleteTeamMemberLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> editTeamMember(
//     teamMemberId,
//     name,
//     role,
//     emailId,
//     phoneNumber,
//     BuildContext context,
//   ) async {
//     try {
//       editLoading = true;
//       notifyListeners();

//       String? response = await TeamMemberServices.editTeamMember(
//         teamMemberId,
//         name,
//         role,
//         emailId,
//         phoneNumber,
//       );

//       if (response == null) {
//         if (!context.mounted) return;
//         showSuccessMessage(
//           context,
//           "Team Member has been successfully updated!",
//         );
//         getAllTeamMembers();
//         pushAndRemoveUntilFun(context, const CreateTeamMemberMain());
//       } else {
//         if (!context.mounted) return;
//         showOverlayError(context, response);
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       editLoading = false;
//       notifyListeners();
//     }
//   }

//   void testSearch(value) {
//     print(value);
//   }

//   Future<void> searchByName(String name) async {
//     try {
//       getTeamMemberLoader = true;
//       notifyListeners();
//       List<TeamMemberModel> teamMemberItems =
//           await TeamMemberServices.searchByName(name);

//       if (teamMemberItems.isNotEmpty) {
//         teamMemberList = teamMemberItems;
//       } else {
//         teamMemberList.clear();
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       getTeamMemberLoader = false;
//       notifyListeners();
//     }
//   }

//   Future<void> getTaskMemberById(memberId) async {
//     try {
//       taskByIdLoading = true;
//       notifyListeners();
//       List<MemberProjectTaskModel> taskItems =
//           await TeamMemberServices.getTaskByMemberId(memberId);

//       if (taskItems.isNotEmpty) {
//         taskList = taskItems;
//       } else {
//         taskList.clear();
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       taskByIdLoading = false;
//       notifyListeners();
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/data-models/member_project_task_model.dart';
import 'package:pokakbilling/models/data-models/teamMember_model.dart';
import 'package:pokakbilling/models/services/team_member_services.dart';
import 'package:pokakbilling/views/Screens/projectmanagement/team_members/create_TM_Main.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class TeamMemberViewmodel extends ChangeNotifier {
  String selectedRoleStatus = "";
  String selectedRoleStatusKey = "";
  bool addTeamLoader = false;
  bool getTeamMemberLoader = false;
  bool singleTeamMemberLoading = false;
  bool deleteTeamMemberLoading = false;
  bool taskByIdLoading = false;
  bool editLoading = false;
  var teamMemberList = <TeamMemberModel>[];
  var singleTeamMemberList = <TeamMemberModel>[];
  var taskList = <MemberProjectTaskModel>[];

  TeamMemberViewmodel() {
    getAllTeamMembers();
  }

  void reset() {
    teamMemberList = [];
    singleTeamMemberList = [];
    taskList = [];
    selectedRoleStatus = "";
    selectedRoleStatusKey = "";
    addTeamLoader = false;
    getTeamMemberLoader = false;
    singleTeamMemberLoading = false;
    deleteTeamMemberLoading = false;
    taskByIdLoading = false;
    editLoading = false;
    notifyListeners();
  }

  void setSelectedRoleStatus(String? status) {
    selectedRoleStatus = status ?? "";
    notifyListeners();
  }

  var roleStatusList = [
    "Full Stack Developer",
    "Frontend Developer",
    "Backend Developer",
    "UI/UX Designer",
    "Project Manager",
    "App Developer",
    "Digital marketing",
    "Tester",
  ];

  void selectRoleStatus(String teamMember) {
    selectedRoleStatus = teamMember;
    switch (teamMember) {
      case "Full Stack Developer":
        selectedRoleStatusKey = "full_stack_developer";
        break;
      case "Frontend Developer":
        selectedRoleStatusKey = "frontend_developer";
        break;
      case "Backend Developer":
        selectedRoleStatusKey = "backend_developer";
        break;
      case "UI/UX Designer":
        selectedRoleStatusKey = "ui_ux_designer";
        break;
      case "Project Manager":
        selectedRoleStatusKey = "project_manager";
        break;
      case "App Developer":
        selectedRoleStatusKey = "app_developer";
        break;
      case "Digital marketing":
        selectedRoleStatusKey = "digital_marketing";
        break;
      case "Tester":
        selectedRoleStatusKey = "tester";
        break;
      default:
        selectedRoleStatusKey = "";
    }
    notifyListeners();
  }

  Future<void> createTeamMember(
    name,
    role,
    emailId,
    phoneNumber,
    BuildContext context,
  ) async {
    try {
      addTeamLoader = true;
      notifyListeners();
      String? response = await TeamMemberServices.createTeamMember(
        name,
        role,
        emailId,
        phoneNumber,
      );
      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Team Member Created Successfully!");
        getAllTeamMembers();
        pushNavigation(context, const CreateTeamMemberMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      addTeamLoader = false;
      notifyListeners();
    }
  }

  Future<void> getAllTeamMembers() async {
    try {
      getTeamMemberLoader = true;
      notifyListeners();
      List<TeamMemberModel> teamMemberItems =
          await TeamMemberServices.getTeamMembers();
      if (teamMemberItems.isNotEmpty) {
        teamMemberList = teamMemberItems;
      } else {
        teamMemberList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      getTeamMemberLoader = false;
      notifyListeners();
    }
  }

  Future<void> getTeamMemberById(teamMemberId) async {
    try {
      singleTeamMemberLoading = true;
      notifyListeners();
      List<TeamMemberModel> customerItems =
          await TeamMemberServices.getTeamMemberById(teamMemberId);
      if (customerItems.isNotEmpty) {
        singleTeamMemberList = customerItems;
      } else {
        singleTeamMemberList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      singleTeamMemberLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMember(teamMemberId, BuildContext context) async {
    try {
      deleteTeamMemberLoading = true;
      notifyListeners();
      String? response =
          await TeamMemberServices.deleteTeamMember(teamMemberId);
      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Team Member Deleted Successfully!");
        getAllTeamMembers();
        pushNavigation(context, const CreateTeamMemberMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      deleteTeamMemberLoading = false;
      notifyListeners();
    }
  }

  Future<void> editTeamMember(
    teamMemberId,
    name,
    role,
    emailId,
    phoneNumber,
    BuildContext context,
  ) async {
    try {
      editLoading = true;
      notifyListeners();
      String? response = await TeamMemberServices.editTeamMember(
        teamMemberId,
        name,
        role,
        emailId,
        phoneNumber,
      );
      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
            context, "Team Member has been successfully updated!");
        getAllTeamMembers();
        pushAndRemoveUntilFun(context, const CreateTeamMemberMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      editLoading = false;
      notifyListeners();
    }
  }

  void testSearch(value) {
    print(value);
  }

  Future<void> searchByName(String name) async {
    try {
      getTeamMemberLoader = true;
      notifyListeners();
      List<TeamMemberModel> teamMemberItems =
          await TeamMemberServices.searchByName(name);
      if (teamMemberItems.isNotEmpty) {
        teamMemberList = teamMemberItems;
      } else {
        teamMemberList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      getTeamMemberLoader = false;
      notifyListeners();
    }
  }

  Future<void> getTaskMemberById(memberId) async {
    try {
      taskByIdLoading = true;
      notifyListeners();
      List<MemberProjectTaskModel> taskItems =
          await TeamMemberServices.getTaskByMemberId(memberId);
      if (taskItems.isNotEmpty) {
        taskList = taskItems;
      } else {
        taskList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      taskByIdLoading = false;
      notifyListeners();
    }
  }
}
