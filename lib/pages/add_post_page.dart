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
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

/// ✅ Samma nyckel används för både Places + Geocoding
String get kGoogleApiKey => dotenv.env['GOOGLE_API_KEY'] ?? '';

class PlaceSuggestion {
  final String description;
  final String placeId;
  PlaceSuggestion({required this.description, required this.placeId});
}

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});
  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  File? _file;
  List<AssetEntity> _recentAssets = [];
  AssetEntity? _selectedAsset;

  bool _isUploading = false;
  final TextEditingController _locationCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (kGoogleApiKey.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google API-nyckel saknas – kontrollera .env-filen'),
          ),
        );
      });
    }

    _loadRecentAssets();
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  // ------------------------ GALLERI: LADDA SENASTE ------------------------
  Future<void> _loadRecentAssets() async {
    final perm = await PhotoManager.requestPermissionExtend();
    final granted = perm.isAuth || perm.hasAccess;
    if (!granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tillåtelse till foton nekad')),
      );
      return;
    }

    final paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
    );
    if (paths.isEmpty) return;

    final recent = await paths.first.getAssetListPaged(page: 0, size: 120);

    if (!mounted) return;
    setState(() {
      _recentAssets = recent;
      if (_recentAssets.isNotEmpty) {
        _selectedAsset = _recentAssets.first;
        _file = null;
      }
    });
  }

  // ------------------------ BILD: KAMERA / PICKER ------------------------
  Future<void> _captureFromCamera() async {
    try {
      final x = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 2400,
      );
      if (x == null) return;
      setState(() {
        _file = File(x.path);
        _selectedAsset = null;
      });
      _loadRecentAssets();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kunde inte ta bild: $e')));
    }
  }

  Future<void> _pickFromSystemGallery() async {
    try {
      final x = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 2400,
      );
      if (x == null) return;
      setState(() {
        _file = File(x.path);
        _selectedAsset = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kunde inte välja bild: $e')));
    }
  }

  // ---- (Behåller plats-funktionerna för nästa sida, men används inte här) ----
  Future<List<PlaceSuggestion>> _fetchAutocomplete(String input) async {
    if (kGoogleApiKey.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Google API-nyckel saknas')));
      return [];
    }
    if (input.trim().isEmpty) return [];
    final uri =
        Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
          'input': input,
          'key': kGoogleApiKey,
          'components': 'country:se',
          'types': 'geocode',
        });

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

  Future<String?> _fetchPlaceLabel(String placeId) async {
    if (kGoogleApiKey.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Google API-nyckel saknas')));
      return null;
    }
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

  Future<void> _useCurrentLocation() async {
    if (kGoogleApiKey.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Google API-nyckel saknas')));
      return;
    }
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

      final settings = const LocationSettings(accuracy: LocationAccuracy.high);
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: settings,
      );

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

  // ------------------------ UPLOAD (sparad till senare) ------------------------
  Future<void> _upload() async {
    File? toUpload = _file;
    if (toUpload == null && _selectedAsset != null) {
      toUpload = await _selectedAsset!.file;
    }

    if (toUpload == null) {
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
        toUpload,
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

    final bigPreview = AspectRatio(
      aspectRatio: 4 / 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: cs.surface,
          alignment: Alignment.center, // 👈 centrera alltid innehållet
          child: _file != null
              ? Image.file(
                  _file!,
                  fit: BoxFit
                      .contain, // 👈 centrera utan beskärning (eller .cover om du vill fylla hela)
                  alignment: Alignment.center,
                )
              : _selectedAsset != null
              ? AssetEntityImage(
                  _selectedAsset!,
                  isOriginal: false,
                  thumbnailSize: const ThumbnailSize.square(1200),
                  fit: BoxFit.contain, // 👈 centrera även Asset-bild
                  alignment: Alignment.center,
                )
              : const Center(child: Text('Ingen bild vald')),
        ),
      ),
    );

    final gridHeight = 180.0;
    final grid = SizedBox(
      height: gridHeight,
      child: _recentAssets.isEmpty
          ? Center(
              child: OutlinedButton.icon(
                onPressed: _pickFromSystemGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Välj från galleri'),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.only(top: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _recentAssets.length + 1, // +1 för kamera-tile
              itemBuilder: (context, index) {
                if (index == 0) {
                  return InkWell(
                    onTap: _isUploading ? null : _captureFromCamera,
                    borderRadius: BorderRadius.circular(12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.photo_camera,
                          color: cs.onPrimary, // 👈 vit ikon
                          size: 28,
                        ),
                      ),
                    ),
                  );
                }

                final asset = _recentAssets[index - 1];
                final isSelected = asset == _selectedAsset && _file == null;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedAsset = asset;
                      _file = null;
                    });
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AssetEntityImage(
                          asset,
                          isOriginal: false,
                          thumbnailSize: const ThumbnailSize.square(300),
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(width: 3, color: cs.primary),
                          ),
                        ),
                    ],
                  ),
                );
              },
              scrollDirection: Axis.vertical,
            ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('New post'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        actions: [
          // i AppBar -> actions i AddPostPage
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddDetailsPage(
                    file: _file, // kan vara null
                    asset: _selectedAsset, // kan vara null
                  ),
                ),
              );
            },
            child: Text(
              'Next',
              style: TextStyle(color: cs.onPrimary, fontSize: 16),
            ),
          ),
        ],
      ),

      // ❌ Post-knapp i botten borttagen
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              bigPreview,
              const SizedBox(height: 12),
              grid,

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed:
                      _pickFromSystemGallery, // 👈 öppnar mobilens galleri direkt
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Go to gallery'),
                  style: TextButton.styleFrom(
                    foregroundColor: cs.primary,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ❌ Location-UI (autocomplete + current location) borttagen här
            ],
          ),
        ),
      ),
    );
  }
}

/// 👉 Placeholder-sida som “Next” leder till
class AddDetailsPage extends StatefulWidget {
  final File? file;
  final AssetEntity? asset;
  const AddDetailsPage({super.key, this.file, this.asset});

  @override
  State<AddDetailsPage> createState() => _AddDetailsPageState();
}

class _AddDetailsPageState extends State<AddDetailsPage> {
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  bool _posting = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  // ---- PLATS: samma som tidigare (autocomplete + label + current location) ----
  Future<List<PlaceSuggestion>> _fetchAutocomplete(String input) async {
    if (kGoogleApiKey.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Google API-nyckel saknas')));
      return [];
    }
    if (input.trim().isEmpty) return [];
    final uri =
        Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
          'input': input,
          'key': kGoogleApiKey,
          'components': 'country:se',
          'types': 'geocode',
        });
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

  Future<String?> _fetchPlaceLabel(String placeId) async {
    if (kGoogleApiKey.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Google API-nyckel saknas')));
      return null;
    }
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

  Future<void> _useCurrentLocation() async {
    if (kGoogleApiKey.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Google API-nyckel saknas')));
      return;
    }
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
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
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

  // ---- POST (återanvänder din uppladdning, men från denna sida) ----
  Future<void> _post() async {
    File? toUpload = widget.file;
    if (toUpload == null && widget.asset != null) {
      toUpload = await widget.asset!.file;
    }
    if (toUpload == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingen bild vald')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Du måste vara inloggad')));
      return;
    }

    setState(() => _posting = true);
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
        toUpload,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await task.ref.getDownloadURL();

      final data = <String, dynamic>{
        'userId': user.uid,
        'username': username,
        'imageUrl': url,
        'locationText': _locationCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'likesCount': 0,
      };

      final desc = _descCtrl.text.trim();
      if (desc.isNotEmpty) {
        data['description'] = desc; // 👈 endast om skrivet
      }

      await FirebaseFirestore.instance.collection('posts').add(data);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Inlägget publicerades!')));
      Navigator.popUntil(context, (r) => r.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Uppladdning misslyckades: $e')));
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  // ----- i AddDetailsPage -----

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New post'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: cs.onPrimary)),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔽 Den här Expanded-sektionen delar på det tillgängliga utrymmet
            //    mellan en mindre bild (flex:3) och ett större beskr.fält (flex:5).
            Expanded(
              child: Column(
                children: [
                  // 📸 Mindre preview
                  Flexible(
                    flex:
                        4, // justera t.ex. till 2 om du vill göra bilden ännu mindre
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        color: cs.surface,
                        alignment: Alignment.center,
                        child: widget.file != null
                            ? Image.file(
                                widget.file!,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              )
                            : (widget.asset != null
                                  ? AssetEntityImage(
                                      widget.asset!,
                                      isOriginal: false,
                                      thumbnailSize: const ThumbnailSize.square(
                                        1600,
                                      ),
                                      fit: BoxFit.cover,
                                      alignment: Alignment.center,
                                    )
                                  : const SizedBox()),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ✏️ Stort multiline-fält (scrollar inuti vid mycket text)
                  Flexible(
                    flex: 2, // större än bilden
                    child: Stack(
                      children: [
                        // Gör TextField fullhöjd och multiline
                        Positioned.fill(
                          child: TextField(
                            controller: _descCtrl,
                            expands: true, // fyller förälderns höjd
                            maxLines: null,
                            minLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              labelText: 'Add description… (optional)',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.fromLTRB(
                                12,
                                12,
                                44,
                                12,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: IconButton(
                            onPressed: () => _descCtrl.clear(),
                            icon: const Icon(Icons.close),
                            tooltip: 'Clear',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 📍 Location-raden ligger kvar under editorn
            Row(
              children: [
                Expanded(
                  child: TypeAheadField<PlaceSuggestion>(
                    controller: _locationCtrl,
                    suggestionsCallback: (q) => _fetchAutocomplete(q),
                    direction: VerticalDirection.up,
                    constraints: const BoxConstraints(maxHeight: 260),
                    offset: const Offset(0, -8),
                    hideOnEmpty: true,
                    debounceDuration: const Duration(milliseconds: 200),

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
                      final better = await _fetchPlaceLabel(s.placeId);
                      if (better != null && better.isNotEmpty) text = better;
                      setState(() => _locationCtrl.text = text);
                    },

                    decorationBuilder: (context, child) => Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: child,
                    ),
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

            const SizedBox(height: 8),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: FilledButton(
            onPressed: _posting ? null : _post,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: _posting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Post'),
          ),
        ),
      ),
    );
  }
}
