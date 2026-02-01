import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  String username = 'User';
  String email = 'user@example.com';
  bool _uploading = false;
  String? _uploadStatus;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        username = user.displayName ?? 'User';
        email = user.email ?? 'user@example.com';
      });
    }
  }

  void _showAlert(BuildContext context, String title, String description) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title: $description'),
        backgroundColor: Colors.deepPurple[900],
      ),
    );
  }

  Future<void> _pickAndUploadFile() async {
    setState(() {
      _uploading = true;
      _uploadStatus = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _uploading = false;
          _uploadStatus = null;
        });
        return;
      }

      final file = result.files.single;
      final path = file.path;
      final name = file.name;

      if (path == null || path.isEmpty) {
        if (file.bytes != null && file.bytes!.isNotEmpty) {
          _showAlert(context, 'Info', 'Web file selection needs different handling.');
        }
        setState(() {
          _uploading = false;
          _uploadStatus = null;
        });
        return;
      }

      final user = _auth.currentUser;
      if (user == null) {
        _showAlert(context, 'Error', 'Not logged in');
        setState(() {
          _uploading = false;
          _uploadStatus = null;
        });
        return;
      }

      final ref = FirebaseStorage.instance
          .ref()
          .child('uploads')
          .child(user.uid)
          .child('${DateTime.now().millisecondsSinceEpoch}_$name');

      final uploadTask = ref.putFile(File(path));

      await uploadTask;

      final downloadUrl = await ref.getDownloadURL();

      setState(() {
        _uploading = false;
        _uploadStatus = 'Uploaded: $name';
      });

      if (mounted) {
        _showAlert(context, 'Success', 'File uploaded successfully');
      }
    } catch (e) {
      setState(() {
        _uploading = false;
        _uploadStatus = null;
      });
      if (mounted) {
        _showAlert(context, 'Upload Failed', e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.deepPurple),
        elevation: 0,
        backgroundColor: Colors.white10,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chatter',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.deepPurple,
                  ),
                ),
                Text(
                  'by ishandeveloper',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 8,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple[900],
              ),
              accountName: Text(username),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://cdn.clipart.email/93ce84c4f719bd9a234fb92ab331bec4_frisco-specialty-clinic-vail-health_480-480.png',
                ),
              ),
              onDetailsPressed: () {},
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              subtitle: Text('Sign out of this account'),
              onTap: () async {
                await _auth.signOut();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 80,
                color: Colors.deepPurple,
              ),
              SizedBox(height: 24),
              Text(
                'Upload Files',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Tap the button below to select and upload a file',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 32),
              if (_uploading)
                Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Uploading...',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton.icon(
                  onPressed: _pickAndUploadFile,
                  icon: Icon(Icons.upload_file),
                  label: Text(
                    'Choose File',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              if (_uploadStatus != null && !_uploading) ...[
                SizedBox(height: 24),
                Text(
                  _uploadStatus!,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
