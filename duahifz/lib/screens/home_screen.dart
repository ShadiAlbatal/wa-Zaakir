import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/dua_provider.dart';
import 'recitation_screen.dart';

/// Home screen displaying list of available Duas
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load Duas when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DuaProvider>().loadDuas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DuaHifz'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<DuaProvider>(
        builder: (context, provider, child) {
          if (provider.duas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading Duas...'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.duas.length,
            itemBuilder: (context, index) {
              final dua = provider.duas[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    dua.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      dua.arabicText,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    await provider.selectDua(dua);
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecitationScreen(),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
