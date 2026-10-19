// lib/models/data-models/lead_model.dart
// UPDATED: added priority (HOT/WARM/COOL), district, campaign, PrioritySummary, LeadPage.

int _toInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('${v ?? ''}') ?? fallback;
}

int? _toIntN(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

String? _toStrN(dynamic v) => v == null ? null : v.toString();

/// Counts for the top HIGH / MEDIUM / LOW priority cards.
class PrioritySummary {
  final int hot;
  final int warm;
  final int cool;
  const PrioritySummary({this.hot = 0, this.warm = 0, this.cool = 0});

  factory PrioritySummary.fromJson(Map<String, dynamic> j) => PrioritySummary(
        hot: _toInt(j['hot']),
        warm: _toInt(j['warm']),
        cool: _toInt(j['cool']),
      );

  factory PrioritySummary.fromLeads(Iterable<LeadModel> leads) {
    int h = 0, w = 0, c = 0;
    for (final l in leads) {
      switch (l.priorityKey) {
        case 'HOT':
          h++;
          break;
        case 'WARM':
          w++;
          break;
        case 'COOL':
          c++;
          break;
      }
    }
    return PrioritySummary(hot: h, warm: w, cool: c);
  }
}

/// Result of GET /leads/ (paginated, with priority_summary).
class LeadPage {
  final List<LeadModel> leads;
  final PrioritySummary? summary;
  final int count;
  const LeadPage({required this.leads, this.summary, this.count = 0});
}

class LeadModel {
  final int id;
  final String? assignedToName;
  final String leadId;
  final String name;
  final String company;
  final String? title;
  final String? description;
  final String? address;
  final String? city;
  final String? state;
  final String? district;
  final String? country;
  final String? location;
  final String email;
  final String phone;
  final String? enquiry;
  final String? projectRequirements;
  final String? additionalNotes;
  final String status;
  final String? source;
  final String? priority; // HOT | WARM | COOL
  final String? receivedDate;
  final String? reason;
  final String createdAt;
  final String updatedAt;
  final int? assignedTo;
  final int? campaign;

  LeadModel({
    required this.id,
    this.assignedToName,
    required this.leadId,
    required this.name,
    required this.company,
    this.title,
    this.description,
    this.address,
    this.city,
    this.state,
    this.district,
    this.country,
    this.location,
    required this.email,
    required this.phone,
    this.enquiry,
    this.projectRequirements,
    this.additionalNotes,
    required this.status,
    this.source,
    this.priority,
    this.receivedDate,
    this.reason,
    required this.createdAt,
    required this.updatedAt,
    this.assignedTo,
    this.campaign,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: _toInt(json['id']),
      assignedToName: _toStrN(json['assigned_to_name']),
      leadId: (json['lead_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      company: (json['company'] ?? '').toString(),
      title: _toStrN(json['title']),
      description: _toStrN(json['description']),
      address: _toStrN(json['address']),
      city: _toStrN(json['city']),
      state: _toStrN(json['state']),
      district: _toStrN(json['district']),
      country: _toStrN(json['country']),
      location: _toStrN(json['location']),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      enquiry: _toStrN(json['enquiry']),
      projectRequirements: _toStrN(json['project_requirements']),
      additionalNotes: _toStrN(json['additional_notes']),
      status: (json['status'] ?? 'NEW').toString(),
      source: _toStrN(json['source']),
      priority: _toStrN(json['priority']),
      receivedDate: _toStrN(json['received_date']),
      reason: _toStrN(json['reason']),
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
      assignedTo: _toIntN(json['assigned_to']),
      campaign: _toIntN(json['campaign']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'assigned_to_name': assignedToName,
        'lead_id': leadId,
        'name': name,
        'company': company,
        'title': title,
        'description': description,
        'address': address,
        'city': city,
        'state': state,
        'district': district,
        'country': country,
        'location': location,
        'email': email,
        'phone': phone,
        'enquiry': enquiry,
        'project_requirements': projectRequirements,
        'additional_notes': additionalNotes,
        'status': status,
        'source': source,
        'priority': priority,
        'received_date': receivedDate,
        'reason': reason,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'assigned_to': assignedTo,
        'campaign': campaign,
      };

  /// HOT / WARM / COOL (upper-case) or '' when not set.
  String get priorityKey => (priority ?? '').trim().toUpperCase();

  String get priorityDisplay {
    switch (priorityKey) {
      case 'HOT':
        return 'Hot';
      case 'WARM':
        return 'Warm';
      case 'COOL':
        return 'Cool';
      default:
        return '';
    }
  }

  /// Human readable status. For OTHER it shows the custom reason.
  String get statusDisplay {
    switch (status.toUpperCase()) {
      case 'NEW':
        return 'New';
      case 'CONTACTED':
        return 'Contacted';
      case 'QUALIFIED':
        return 'Qualified';
      case 'CONVERTED':
        return 'Converted';
      case 'LOST':
        return 'Lost';
      case 'OTHER':
        return (reason != null && reason!.trim().isNotEmpty)
            ? reason!.trim()
            : 'Other';
      default:
        return status;
    }
  }
}