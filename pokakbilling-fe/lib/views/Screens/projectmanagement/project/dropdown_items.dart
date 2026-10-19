class DropdownItem {
  final String id;
  final String name;

  DropdownItem({required this.id, required this.name});

  @override
  String toString() => name; // So that it shows the name in Dropdown
}