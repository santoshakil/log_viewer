import 'dart:io' show File;

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart'
    show
        BuildContext,
        Center,
        CircularProgressIndicator,
        Color,
        Colors,
        CrossAxisAlignment,
        Expanded,
        FutureBuilder,
        Icon,
        IconButton,
        Icons,
        ListView,
        Row,
        StatelessWidget,
        StreamBuilder,
        Text,
        TextStyle,
        Widget;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;

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
        return FutureBuilder<List<String>>(
          future: compute(
              (path) async =>
                  (await File(path).readAsLines()).reversed.toList(),
              path),
          builder: (_, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final line = snapshot.data![index];
                final parts = line.split(' - ');
                if (parts.length != 3) return Text(line);
                final time = DateFormat('dd-MMM-yyyy hh:mm:ss a')
                    .format(DateTime.parse(parts[0]).toLocal());
                final type = parts[1];
                final message = parts[2];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$time - $type: ',
                        style: TextStyle(color: _colorForType(type))),
                    Expanded(child: Text(message)),
                    IconButton(
                      onPressed: () async => await Clipboard.setData(
                        ClipboardData(text: message),
                      ),
                      icon: const Icon(Icons.copy),
                    )
                  ],
                );
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
