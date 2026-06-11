// String _supportMessage(SupportContact contact) {
//     return '''Hi ${contact.name},

// I'm having a difficult time right now and could really use someone to talk to.

// Can you check in with me when you're free?

// - Sent through Serenova''';
//   }

//   String _whatsAppNumber(String phone) {
//     return phone.replaceAll(RegExp(r'[^0-9]'), '');
//   }

//   Future<void> _launchUri(Uri uri) async {
//     if (!await canLaunchUrl(uri)) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Could not open the selected app.')),
//         );
//       }
//       return;
//     }

//     await launchUrl(uri, mode: LaunchMode.externalApplication);
//   }

//   Future<void> _sendSupportMessage(SupportContact contact,
//       {required bool useWhatsApp}) async {
//     final message = Uri.encodeComponent(_supportMessage(contact));
//     final cleanPhone = _whatsAppNumber(contact.phone);
//     final uri = useWhatsApp
//         ? Uri.parse('https://wa.me/$cleanPhone?text=$message')
//         : Uri(scheme: 'sms', path: contact.phone, queryParameters: {
//             'body': _supportMessage(contact),
//           });
//     await _launchUri(uri);
//   }

//   Future<void> _callContact(SupportContact contact) async {
//     await _launchUri(Uri(scheme: 'tel', path: contact.phone));
//   }

//   Future<void> _deleteContact(String contactId) async {
//     final currentUserId = _currentUserId();
//     await _supportCircleRepo.deleteContact(currentUserId, contactId);
//   }

//   Future<void> _saveContact({
//     SupportContact? existing,
//     required String name,
//     required String phone,
//     required String relationship,
//   }) async {
//     final currentUserId = _currentUserId();
//     final contactId = existing?.id ?? FirebaseFirestore.instance
//         .collection('customers')
//         .doc(currentUserId)
//         .collection('supportCircle')
//         .doc()
//         .id;

//     final contact = SupportContact(
//       id: contactId,
//       name: name.trim(),
//       phone: phone.trim(),
//       relationship: relationship,
//     );

//     if (existing == null) {
//       await _supportCircleRepo.addContact(currentUserId, contact);
//     } else {
//       await _supportCircleRepo.updateContact(currentUserId, contact);
//     }

//     if (mounted) {
//       setState(() {});
//     }
//   }

//   Future<void> _openContactEditor({
//     SupportContact? contact,
//     required int currentCount,
//   }) async {
//     if (contact == null && currentCount >= 5) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('You can save up to 5 support contacts.')),
//       );
//       return;
//     }

//     final nameController = TextEditingController(text: contact?.name ?? '');
//     final phoneController = TextEditingController(text: contact?.phone ?? '');
//     String relationship = contact?.relationship ?? 'Friend';
//     const relationships = ['Friend', 'Parent', 'Sibling', 'Mentor', 'Other'];

//     await showDialog<void>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: Text(contact == null ? 'Add Support Contact' : 'Update Support Contact'),
//           content: StatefulBuilder(
//             builder: (context, setDialogState) {
//               return SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       controller: nameController,
//                       decoration: const InputDecoration(labelText: 'Name'),
//                     ),
//                     TextField(
//                       controller: phoneController,
//                       decoration: const InputDecoration(labelText: 'Phone'),
//                       keyboardType: TextInputType.phone,
//                     ),
//                     DropdownButtonFormField<String>(
//                       value: relationship,
//                       decoration: const InputDecoration(labelText: 'Relationship'),
//                       items: relationships
//                           .map(
//                             (option) => DropdownMenuItem(
//                               value: option,
//                               child: Text(option),
//                             ),
//                           )
//                           .toList(),
//                       onChanged: (value) {
//                         if (value != null) {
//                           setDialogState(() {
//                             relationship = value;
//                           });
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(dialogContext),
//               child: const Text('Cancel'),
//             ),
//             FilledButton(
//               onPressed: () async {
//                 if (nameController.text.trim().isEmpty ||
//                     phoneController.text.trim().isEmpty) {
//                   return;
//                 }

//                 await _saveContact(
//                   existing: contact,
//                   name: nameController.text,
//                   phone: phoneController.text,
//                   relationship: relationship,
//                 );

//                 if (mounted) {
//                   Navigator.pop(dialogContext);
//                 }
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _openSOSSheet(List<SupportContact> contacts) async {
//     await showModalBottomSheet<void>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (sheetContext) {
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Need Immediate Support?',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'Pick a trusted contact and open SMS or WhatsApp with a pre-written check-in message.',
//                   style: TextStyle(color: Colors.black54),
//                 ),
//                 const SizedBox(height: 16),
//                 if (contacts.isEmpty)
//                   const Text(
//                     'Add at least one trusted contact first.',
//                     style: TextStyle(color: Colors.grey),
//                   )
//                 else
//                   ListView.separated(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: contacts.length,
//                     separatorBuilder: (_, __) => const SizedBox(height: 12),
//                     itemBuilder: (context, index) {
//                       final contact = contacts[index];
//                       return Container(
//                         padding: const EdgeInsets.all(14),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade50,
//                           borderRadius: BorderRadius.circular(18),
//                           border: Border.all(color: Colors.grey.shade300),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               contact.name,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text('${contact.relationship} • ${contact.phone}'),
//                             const SizedBox(height: 12),
//                             Wrap(
//                               spacing: 8,
//                               runSpacing: 8,
//                               children: [
//                                 TextButton.icon(
//                                   onPressed: () => _callContact(contact),
//                                   icon: const Icon(Icons.call),
//                                   label: const Text('Call'),
//                                 ),
//                                 TextButton.icon(
//                                   onPressed: () => _sendSupportMessage(
//                                       contact,
//                                       useWhatsApp: false),
//                                   icon: const Icon(Icons.message),
//                                   label: const Text('SMS'),
//                                 ),
//                                 TextButton.icon(
//                                   onPressed: () => _sendSupportMessage(
//                                       contact,
//                                       useWhatsApp: true),
//                                   icon: const Icon(Icons.chat),
//                                   label: const Text('WhatsApp'),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/supportcontactsmodel.dart';

String supportMessage(SupportContact contact) {
  return '''
Hi ${contact.name},

I'm having a difficult time right now and could really use someone to talk to.

Can you check in with me when you're free?

- Sent through Serenova
''';
}

String whatsAppNumber(String phone) {
  return phone.replaceAll(RegExp(r'[^0-9]'), '');
}

Future<void> launchSOSUri(
  BuildContext context,
  Uri uri,
) async {
  if (!await canLaunchUrl(uri)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not open app'),
      ),
    );

    return;
  }

  await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );
}

Future<void> sendSupportMessage(
  BuildContext context,
  SupportContact contact, {
  required bool useWhatsApp,
}) async {
  final message = Uri.encodeComponent(
    supportMessage(contact),
  );

  final cleanPhone = whatsAppNumber(contact.phone);

  final uri = useWhatsApp
      ? Uri.parse(
          'https://wa.me/$cleanPhone?text=$message',
        )
      : Uri(
          scheme: 'sms',
          path: contact.phone,
          queryParameters: {
            'body': supportMessage(contact),
          },
        );

  await launchSOSUri(
    context,
    uri,
  );
}

Future<void> callContact(
  BuildContext context,
  SupportContact contact,
) async {
  await launchSOSUri(
    context,
    Uri(
      scheme: 'tel',
      path: contact.phone,
    ),
  );
}

Future<void> showSOSSheet(
  BuildContext context,
  List<SupportContact> contacts,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Need Immediate Support?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pick a trusted contact and open SMS or WhatsApp with a pre-written check-in message.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              if (contacts.isEmpty)
                const Text(
                  'Add at least one trusted contact first.',
                  style: TextStyle(color: Colors.grey),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: contacts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('${contact.relationship} • ${contact.phone}'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              TextButton.icon(
                                onPressed: () => callContact(context, contact),
                                icon: const Icon(Icons.call),
                                label: const Text('Call'),
                              ),
                              TextButton.icon(
                                onPressed: () => sendSupportMessage(
                                    context, contact,
                                    useWhatsApp: false),
                                icon: const Icon(Icons.message),
                                label: const Text('SMS'),
                              ),
                              TextButton.icon(
                                onPressed: () => sendSupportMessage(
                                    context, contact,
                                    useWhatsApp: true),
                                icon: const Icon(Icons.chat),
                                label: const Text('WhatsApp'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}
