import 'dart:io';
import 'dart:isolate';

import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

const host = 'localhost';
const port = 8080;

var app = Router();

/// A version of the API that uses a number of workers equal to CPU cores (10)
Future<void> main() async {
  final cores = await _getCores();
  print('This computer has $cores CPU cores');

  for (var i = 1; i < cores; i++) {
    Isolate.spawn((i) => _startServer('isolate:$i'), i + 1);
  }
  _startServer('main');
}

Future<int> _getCores() async {
  final result = await Process.run('nproc', []);
  return int.tryParse(result.stdout) ?? 1;
}

Future<void> _startServer(String id) async {
  app.get('/health', (Request request) {
    return Response.ok('OK');
  });

  print('[$id]: serving on $host:$port');
  await io.serve(app, host, port, shared: true);
}
