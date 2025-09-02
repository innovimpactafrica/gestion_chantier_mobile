import 'package:flutter/material.dart';
import 'package:gestion_chantier/moa/models/documents.dart';
import 'package:gestion_chantier/moa/utils/HexColor.dart';

class DocumentSearchPage extends StatefulWidget {
  final List<DocumentModel> documents;
  const DocumentSearchPage({super.key, required this.documents});

  @override
  State<DocumentSearchPage> createState() => _DocumentSearchPageState();
}

class _DocumentSearchPageState extends State<DocumentSearchPage> {
  String searchQuery = '';
  late List<DocumentModel> filteredDocuments;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    filteredDocuments = widget.documents;
    _controller = TextEditingController();
  }

  void _filterDocuments(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredDocuments = widget.documents;
      } else {
        filteredDocuments =
            widget.documents
                .where(
                  (doc) =>
                      doc.title.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: HexColor('#183153'),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: TextStyle(color: Colors.white, fontSize: 22),
          decoration: InputDecoration(
            hintText: 'Rechercher ici',
            hintStyle: TextStyle(color: Colors.white70, fontSize: 22),
            border: InputBorder.none,
          ),
          onChanged: _filterDocuments,
        ),
      ),
      body:
          searchQuery.isEmpty
              ? Container() // page vide tant que rien n'est tapé
              : (filteredDocuments.isEmpty
                  ? Center(child: Text('Aucun document trouvé'))
                  : ListView.builder(
                    itemCount: filteredDocuments.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocuments[index];
                      return ListTile(
                        title: Text(doc.title),
                        subtitle:
                            doc.description != null
                                ? Text(doc.description)
                                : null,
                      );
                    },
                  )),
    );
  }
}
