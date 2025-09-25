import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class TravellersListScreen extends StatelessWidget {
  final List<Traveller> travellers;
  final Function(Traveller) onTravellerSelected;
  final VoidCallback? onBackPressed;

  const TravellersListScreen({
    super.key,
    required this.travellers,
    required this.onTravellerSelected,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des voyageurs'),
        backgroundColor: const Color(0xFF1D5E9B),
        foregroundColor: Colors.white,
        leading: onBackPressed != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBackPressed,
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: travellers.length,
          itemBuilder: (context, index) {
            final traveller = travellers[index];
            final user = traveller.user;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: user?.picture != null
                      ? ClipOval(
                          child: Image.network(
                            user!.picture!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                color: Colors.blue,
                                size: 30,
                              );
                            },
                          ),
                        )
                      : const Icon(Icons.person, color: Colors.blue, size: 30),
                ),
                title: Text(
                  '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: user?.email != null
                    ? Text(
                        user!.email!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      )
                    : null,
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: () => onTravellerSelected(traveller),
              ),
            );
          },
        ),
      ),
    );
  }
}
