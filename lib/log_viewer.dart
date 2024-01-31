import 'dart:io' show File;

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart'
    show
        BuildContext,
        Center,
        CircularProgressIndicator,
        Color,
        Colors,
        FutureBuilder,
        ListView,
        StatelessWidget,
        StreamBuilder,
        Text,
        TextStyle,
        Widget;

class LogViewer extends StatelessWidget {
  const LogViewer({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: File(path).watch(),
      builder: (_, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        // final lines = const LineSplitter().convert(file.readAsStringSync());
        return FutureBuilder(
          future: compute((path) => File(path).readAsLines(), path),
          builder: (_, snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final lines = snapshot.data as List<String>;
            return ListView.builder(
              itemCount: lines.length,
              itemBuilder: (context, index) {
                final line = lines[index];
                final parts = line.split(' - ');
                if (parts.length == 1) return Text(line);
                final time = parts[0];
                final type = parts[1];
                final message = parts[2];
                return Text('$time - $type - $message', style: TextStyle(color: _colorForType(type)));
              },
            );
          },
        );
      },
    );
  }
}

Color? _colorForType(String type) => switch (type.toLowerCase()) {
      'warning' => Colors.yellow.shade50,
      'error' => Colors.red,
      _ => null,
    };
