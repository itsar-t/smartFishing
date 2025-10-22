import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';

/// ✅ Samma nyckel kan användas för både Places + Geocoding, så länge båda är aktiverade
const String kGoogleApiKey = 'AIzaSyA7SG-AFo7zXYaF96hqeOlIMxeOD3g-EUU';

/// Enkel modell för Places-förslag
class PlaceSuggestion {
  final String description;
  final String placeId;
  PlaceSuggestion({required this.description, required this.placeId});
}

/// AddPostPage – välj bild, plats (med autocomplete & current location), ladda upp till Storage
class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  File? _file;
  bool _isUploading = false;
  final TextEditingController _locationCtrl = TextEditingController();

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  // ------------------------ BILD ------------------------

  Future<void> _pickImage(ImageSource source) async {
    try {
      final x = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2400,
      );
      if (x == null) return;
      setState(() => _file = File(x.path));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kunde inte välja bild: $e')));
    }
  }

  // ------------------------ PLATS: AUTOCOMPLETE + DETAILS ------------------------

  Future<List<PlaceSuggestion>> _fetchAutocomplete(String input) async {
    if (input.trim().isEmpty) return [];
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {
        'input': input,
        'key': kGoogleApiKey,
        // Vill du globalt? Ta bort raden nedan
        'components': 'country:se',
        'types': 'geocode',
      },
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) return [];
    final data = json.decode(res.body) as Map<String, dynamic>;
    final preds = (data['predictions'] as List?) ?? [];
    return preds
        .map(
          (p) => PlaceSuggestion(
            description: (p['description'] ?? '') as String,
            placeId: (p['place_id'] ?? '') as String,
          ),
        )
        .toList();
  }

  /// Hämta “snyggare” text (name + formatted_address) för ett placeId
  Future<String?> _fetchPlaceLabel(String placeId) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      {
        'place_id': placeId,
        'key': kGoogleApiKey,
        'fields': 'name,formatted_address',
      },
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) return null;
    final data = json.decode(res.body) as Map<String, dynamic>;
    final result = data['result'] as Map<String, dynamic>?;
    if (result == null) return null;
    final name = result['name'] as String?;
    final addr = result['formatted_address'] as String?;
    return (name != null && addr != null) ? '$name, $addr' : (addr ?? name);
  }

  // ------------------------ PLATS: CURRENT LOCATION + REVERSE GEOCODING ------------------------

  Future<void> _useCurrentLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }

      final settings = LocationSettings(accuracy: LocationAccuracy.high);
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: settings,
      );

      // Reverse geocoding med Google Geocoding API
      final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        'latlng': '${pos.latitude},${pos.longitude}',
        'key': kGoogleApiKey,
      });
      final res = await http.get(uri);

      String label = '${pos.latitude}, ${pos.longitude}';
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final results = (data['results'] as List?) ?? [];
        if (results.isNotEmpty) {
          label = results.first['formatted_address'] as String? ?? label;
        }
      }

      setState(() => _locationCtrl.text = label);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kunde inte hämta plats: $e')));
    }
  }

  // ------------------------ UPLOAD ------------------------

  Future<void> _upload() async {
    if (_file == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Välj en bild först')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Du måste vara inloggad')));
      return;
    }

    setState(() => _isUploading = true);

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final username = (userDoc.data()?['username'] ?? 'user') as String;

      final ts = DateTime.now().millisecondsSinceEpoch;
      final path = 'posts/${user.uid}/$ts.jpg';

      final ref = FirebaseStorage.instance.ref().child(path);
      final task = await ref.putFile(
        _file!,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await task.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('posts').add({
        'userId': user.uid,
        'username': username,
        'imageUrl': url,
        'locationText': _locationCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'likesCount': 0,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Inlägget publicerades!')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Uppladdning misslyckades: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ------------------------ UI ------------------------

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add post'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Centrerat innehåll + scroll när tangentbordet öppnas
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Padding(
                        // luft för tangentbord + den fixerade knappen
                        padding: EdgeInsets.only(
                          bottom:
                              MediaQuery.of(context).viewInsets.bottom + 100,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_file == null)
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _isUploading
                                          ? null
                                          : () =>
                                                _pickImage(ImageSource.gallery),
                                      icon: const Icon(Icons.photo),
                                      label: const Text('Gallery'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _isUploading
                                          ? null
                                          : () =>
                                                _pickImage(ImageSource.camera),
                                      icon: const Icon(Icons.photo_camera),
                                      label: const Text('Camera'),
                                    ),
                                  ),
                                ],
                              )
                            else
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 4 / 5,
                                      child: Image.file(
                                        _file!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      right: 8,
                                      bottom: 8,
                                      child: FloatingActionButton.small(
                                        heroTag: 'changeImageFab',
                                        backgroundColor: cs.inversePrimary,
                                        onPressed: _isUploading
                                            ? null
                                            : () => _pickImage(
                                                ImageSource.gallery,
                                              ),
                                        child: Icon(
                                          Icons.swap_horiz,
                                          color: cs.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 16),

                            // 🔎 Autocomplete + 📍 current location
                            Row(
                              children: [
                                Expanded(
                                  child: TypeAheadField<PlaceSuggestion>(
                                    controller: _locationCtrl,
                                    suggestionsCallback: (q) =>
                                        _fetchAutocomplete(q),
                                    builder: (context, controller, focusNode) {
                                      return TextField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        textInputAction: TextInputAction.done,
                                        decoration: const InputDecoration(
                                          labelText: 'Location (optional)',
                                          border: OutlineInputBorder(),
                                        ),
                                      );
                                    },
                                    itemBuilder: (context, s) => ListTile(
                                      leading: const Icon(Icons.place),
                                      title: Text(s.description),
                                    ),
                                    onSelected: (s) async {
                                      var text = s.description;
                                      final better = await _fetchPlaceLabel(
                                        s.placeId,
                                      );
                                      if (better != null && better.isNotEmpty) {
                                        text = better;
                                      }
                                      setState(() => _locationCtrl.text = text);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filledTonal(
                                  onPressed: _useCurrentLocation,
                                  icon: const Icon(Icons.my_location),
                                  tooltip: 'Use current location',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // 🔽 Fixerad Post-knapp i botten
            Positioned(
              left: 16,
              right: 16,
              bottom: 48,
              child: FilledButton(
                onPressed: _isUploading ? null : _upload,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
