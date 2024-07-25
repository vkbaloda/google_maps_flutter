// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// The `GroundOverlayController` class wraps a [gmaps.GroundOverlay] and its `onTap` behavior.
class GroundOverlayController {
  /// Creates a `GroundOverlayController` that wraps a [gmaps.GroundOverlay] object and its `onTap` behavior.
  GroundOverlayController({
    required gmaps.GroundOverlay groundOverlay,
    bool consumeTapEvents = false,
    ui.VoidCallback? onTap,
  })  : _groundOverlay = groundOverlay,
        _consumeTapEvents = consumeTapEvents {
    // Setup onClick listener if onTap is provided
    if (onTap != null) {
      groundOverlay.onClick.listen((gmaps.MapMouseEvent event) {
        // Check if the click is within the bounds of the GroundOverlay
        if (_isClickInsideGroundOverlay(event)) {
          onTap.call();
        }
      });
    }
  }

  gmaps.GroundOverlay? _groundOverlay;

  final bool _consumeTapEvents;

  /// Returns the wrapped [gmaps.GroundOverlay]. Only used for testing.
  @visibleForTesting
  gmaps.GroundOverlay? get groundOverlay => _groundOverlay;

  /// Returns `true` if this Controller will use its own `onTap` handler to consume events.
  bool get consumeTapEvents => _consumeTapEvents;

  /// Updates the options of the wrapped [gmaps.GroundOverlay] object.
  ///
  /// This cannot be called after [remove].
  void update(gmaps.GroundOverlayOptions options) {
    assert(_groundOverlay != null,
        'Cannot `update` GroundOverlay after calling `remove`.');
    // No other option need to be updated
    _groundOverlay!.opacity = options.opacity;
  }

  /// Disposes of the currently wrapped [gmaps.GroundOverlay].
  void remove() {
    if (_groundOverlay != null) {
      // _groundOverlay!.visible = false;
      _groundOverlay!.map = null;
      _groundOverlay = null;
    }
  }

  /// Checks if the mouse click is inside the bounds of the GroundOverlay.
  bool _isClickInsideGroundOverlay(gmaps.MapMouseEvent event) {
    if (_groundOverlay == null || _groundOverlay!.map == null) {
      return false;
    }

    final gmaps.LatLngBounds bounds = _groundOverlay!.bounds!;

    // Convert screen coordinates to LatLng
    final gmaps.Projection projection = _groundOverlay!.map!.projection!;
    final gmaps.LatLng? latLng = projection.fromPointToLatLng?.call(
      gmaps.Point(event.latLng?.lat, event.latLng?.lng),
    );

    return bounds.contains(latLng) ?? false;
  }
}
