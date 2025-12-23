import 'package:firebase_google_apple_notif/app/components/my_chip.dart';
import 'package:firebase_google_apple_notif/model/patner_model.dart';
import 'package:firebase_google_apple_notif/services/admin_service.dart';
import 'package:flutter/material.dart';

class ManagePartensScreen extends StatefulWidget {
  const ManagePartensScreen({super.key});

  @override
  State<ManagePartensScreen> createState() => _ManagePartensScreenState();
}

class _ManagePartensScreenState extends State<ManagePartensScreen> {
  final AdminService _service = AdminService();

  bool _loading = true;
  List<PartnerModel> _partners = [];

  @override
  void initState() {
    super.initState();
    _loadPartners();
  }

  Future<void> _loadPartners() async {
    final data = await _service.fetchPartners(context);
    if (!mounted) return;

    setState(() {
      _partners = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff121212),
      appBar: AppBar(
        backgroundColor: const Color(0xff2A2A2A),
        title: const Center(
          child: Text(
            'Partners',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.amber,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            Container(
              padding: const EdgeInsets.only(left: 10),
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xff2A2A2A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const TextField(
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
            const SizedBox(height: 15),
            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  MyChip(text: 'All(4)', color: Colors.amber),
                  SizedBox(width: 10),
                  MyChip(text: 'Pending(0)', color: Color(0xff2A2A2A)),
                  SizedBox(width: 10),
                  MyChip(text: 'Approved(4)', color: Color(0xff2A2A2A)),
                  SizedBox(width: 10),
                  MyChip(text: 'Rejected(0)', color: Color(0xff2A2A2A)),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Center(
              child: Text(
                'Showing ${_partners.length} partners',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            const SizedBox(height: 10),
            // Add Partner
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(
                    strokeAlign: 1,
                    color: Color(0xff2A2A2A),
                    width: 1.2,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add),
                  SizedBox(width: 5),
                  Text(
                    'Add New Parntner',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Partners List
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    )
                  : _partners.isEmpty
                  ? const Center(
                      child: Text(
                        'No partners found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _partners.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PartnerCard(partner: _partners[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class PartnerCard extends StatelessWidget {
  final PartnerModel partner;

  const PartnerCard({super.key, required this.partner});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xff121212),
        border: Border.all(color: Colors.white60),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: Colors.black,
            child: Icon(Icons.business_sharp, color: Colors.white),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partner.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  partner.company,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        partner.email,
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_android_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      partner.phone,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      partner.location,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                Text(
                  'Applied: ${partner.appliedDate}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    partner.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
