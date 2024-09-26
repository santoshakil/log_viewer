import 'dart:io' show File;

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart'
    show
        BuildContext,
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
        SizedBox,
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
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (_, __) {
        return FutureBuilder<List<String>>(
          future: compute((p) async => (await File(p).readAsLines()).reversed.toList(), path),
          builder: (_, v) {
            if (v.data == null) return const SizedBox.shrink();
            return ListView.builder(
              itemCount: v.data!.length,
              itemBuilder: (_, i) {
                final line = v.data![i];
                final parts = line.split(' - ');
                if (parts.length != 3) return Text(line);
                final time = DateFormat('dd-MMM-yyyy hh:mm:ss a').format(DateTime.parse(parts[0]).toLocal());
                final type = parts[1];
                final msg = parts[2];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$time - $type: ', style: TextStyle(color: _colorForType(type))),
                    Expanded(child: Text(msg)),
                    IconButton(
                      onPressed: () async => await Clipboard.setData(ClipboardData(text: msg)),
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
