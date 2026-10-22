# Third-party notices

## Swiss Ephemeris and `sweph`

AstroGuide uses the [`sweph` Flutter package](https://pub.dev/packages/sweph),
which includes Swiss Ephemeris code and ephemeris data. The default open-source
distribution is governed by AGPL-3.0-only and carries additional Astrodienst
notice and source-availability requirements. See the package's
[`LICENSING.md`](https://github.com/vm75/sweph.dart/blob/main/LICENSING.md)
and bundled dependency notices before redistributing the app or operating the
API for others.

## GeoNames

The bundled Indonesian populated-place data is derived from
[GeoNames](https://www.geonames.org/), `https://download.geonames.org/export/dump/ID.zip`,
and is used under the Creative Commons Attribution 4.0 License (CC BY 4.0).
The app stores only place names, GeoNames IDs, region codes, population,
coordinates, and IANA time-zone identifiers. Refresh the offline data with
`tools/update-indonesia-cities.ps1`.
