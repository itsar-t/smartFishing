import 'dart:math' as math;
import 'package:flutter_map/flutter_map.dart'
    show TileProvider, TileCoordinates, TileLayer;
import 'package:flutter/painting.dart';
// no foundation imports needed

/// Convert tile x,y,z (slippy map) to a WebMercator (EPSG:3857) bounding box.
/// Returns bbox as "minX,minY,maxX,maxY" in EPSG:3857 meters.
String tileBboxEpsg3857(int x, int y, int z) {
  final n = math.pow(2, z);
  // tile to lon/lat in web mercator (lon, lat)
  double lonLeft = x / n * 360.0 - 180.0;
  double lonRight = (x + 1) / n * 360.0 - 180.0;

  double latTop = _tile2lat(y, z);
  double latBottom = _tile2lat(y + 1, z);

  // convert lon/lat to WebMercator meters
  final min = _lonLatToWebMercator(lonLeft, latBottom);
  final max = _lonLatToWebMercator(lonRight, latTop);

  return '${min[0]},${min[1]},${max[0]},${max[1]}';
}

double _tile2lat(int y, int z) {
  final n = math.pi - 2.0 * math.pi * y / math.pow(2, z);
  return (180.0 / math.pi) * math.atan(0.5 * (math.exp(n) - math.exp(-n)));
}

List<double> _lonLatToWebMercator(double lon, double lat) {
  // Web mercator (EPSG:3857)
  final x = lon * 20037508.34 / 180.0;
  var y = math.log(math.tan((90 + lat) * math.pi / 360.0)) / (math.pi / 180.0);
  y = y * 20037508.34 / 180.0;
  return [x, y];
}

/// A simple TileProvider that builds WMS GetMap URLs per tile.
///
/// Example usage:
/// TileLayer(
///   tileProvider: WmsTileProvider(
///     baseUrl: 'https://yourserver/wms',
///     layers: 'layer_name',
///     version: '1.3.0',
///     format: 'image/png',
///     transparent: true,
///   ),
/// )
class WmsTileProvider extends TileProvider {
  final String baseUrl;
  final String layers;
  final String version;
  final String format;
  final bool transparent;
  final String crs; // typically 'EPSG:3857' or 'EPSG:4326'
  final int tileSize;

  WmsTileProvider({
    required this.baseUrl,
    required this.layers,
    this.version = '1.3.0',
    this.format = 'image/png',
    this.transparent = true,
    this.crs = 'EPSG:3857',
    this.tileSize = 256,
  });

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    // Build the full URL for this tile
    final x = coordinates.x;
    final y = coordinates.y;
    final z = coordinates.z;

    final bbox = tileBboxEpsg3857(x, y, z);

    // For WMS 1.3.0 the axis order can be lat,lon for some CRSes; EPSG:3857 uses bbox as minx,miny,maxx,maxy (meters)
    final url = Uri.parse(baseUrl)
        .replace(
          queryParameters: {
            'SERVICE': 'WMS',
            'REQUEST': 'GetMap',
            'VERSION': version,
            'LAYERS': layers,
            'STYLES': '',
            'FORMAT': format,
            'TRANSPARENT': transparent ? 'TRUE' : 'FALSE',
            'WIDTH': tileSize.toString(),
            'HEIGHT': tileSize.toString(),
            'CRS': crs,
            'BBOX': bbox,
          },
        )
        .toString();

    return NetworkImage(url);
  }
}
