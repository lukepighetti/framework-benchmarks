import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

const host = 'localhost';
const port = 8080;

var app = Router();

Future<void> main() async {
  app.get('/health', (Request request) {
    return Response.ok('OK');
  });

  print('serving on $host:$port');
  await io.serve(app, host, port);
}
