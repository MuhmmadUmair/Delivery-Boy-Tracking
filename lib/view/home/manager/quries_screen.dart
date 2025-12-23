import 'package:flutter/material.dart';
import 'package:firebase_google_apple_notif/repository/admin_repository.dart';
import 'package:firebase_google_apple_notif/model/query_model.dart';
import 'package:firebase_google_apple_notif/app/components/my_text_field.dart';

class QuriesScreen extends StatefulWidget {
  const QuriesScreen({super.key});

  @override
  State<QuriesScreen> createState() => _QuriesScreenState();
}

class _QuriesScreenState extends State<QuriesScreen> {
  final AdminRepository _repository = AdminRepository();
  late Future<List<QueryModel>> _queriesFuture;

  @override
  void initState() {
    super.initState();
    _queriesFuture = _repository.getQueries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff121212),
      appBar: AppBar(
        backgroundColor: const Color(0xff121212),
        title: const Center(
          child: Text(
            'Queries',
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: FutureBuilder<List<QueryModel>>(
        future: _queriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final queries = snapshot.data ?? [];
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: queries.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              if (index == 0)
                return const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: MyTextField(),
                );
              final query = queries[index - 1];
              return Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xff333333),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white38),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(child: Icon(Icons.person)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            query.nameTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            query.purpose,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            query.location,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            query.createdAt,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            query.status,
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: Icon(Icons.check, color: Colors.green),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
