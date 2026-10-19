// Single source of truth for lead statuses (label shown in UI → key sent to API).
// Order here is the order shown in the dropdowns.

class LeadStatusOption {
  final String key;
  final String label;
  const LeadStatusOption(this.key, this.label);
}

const List<LeadStatusOption> kLeadStatusOptions = [
  LeadStatusOption('new', 'New'),
  LeadStatusOption('contacted', 'Contacted'),
  LeadStatusOption('lost', 'Lost'),
  LeadStatusOption('follow_up', 'Follow Up'),
  LeadStatusOption('created', 'Created'),
  LeadStatusOption('in_progress', 'In Progress'),
  LeadStatusOption('converted', 'Converted'),
  LeadStatusOption('rnr', 'Rnr'),
  LeadStatusOption('prospects', 'Prospects'),
  LeadStatusOption('details_shared', 'Details shared'),
  LeadStatusOption('registration', 'Registration'),
  LeadStatusOption('other', 'Other'), // ← NEW
];

List<String> get kLeadStatusLabels =>
    kLeadStatusOptions.map((o) => o.label).toList();

String _norm(String s) =>
    s.trim().toLowerCase().replaceAll('_', ' ').replaceAll(RegExp(r'\s+'), ' ');

/// Finds a status by label OR key, case-insensitive.
/// "Follow Up", "follow_up", "follow up" all resolve to the same option.
LeadStatusOption? findLeadStatus(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final v = _norm(value);
  for (final o in kLeadStatusOptions) {
    if (_norm(o.label) == v || _norm(o.key) == v) return o;
  }
  return null;
}