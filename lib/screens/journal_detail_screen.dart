import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'journal_entry.dart';

class JournalDetailScreen extends StatelessWidget {
  final JournalEntry entry;

  const JournalDetailScreen({Key? key, required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(entry.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
              ),
              SizedBox(height: 8),
              Text(
                DateFormat('MMM dd, yyyy • hh:mm a').format(entry.date),
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 16),

              // Check if imagePath is not null and not empty before displaying
              if ((entry.imagePath ?? '').isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(entry.imagePath!), fit: BoxFit.cover),
                ),

              SizedBox(height: 16),
              Text(
                entry.content,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),

              // Check if mood is not null and not empty
              if ((entry.mood ?? '').isNotEmpty)
                Text(
                  "Mood: ${entry.mood}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
                ),

              // Check if tags list is not null and not empty
              if ((entry.tags ?? []).isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: (entry.tags ?? [])
                      .map((tag) => Chip(label: Text(tag, style: TextStyle(color: Colors.white)), backgroundColor: Colors.pinkAccent))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
