// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// This class manages a set of [GroundOverlayController]s associated with a [GoogleMapController].
class GroundOverlaysController extends GeometryController {
  /// Initializes the cache. The [StreamController] comes from the [GoogleMapController] and is shared with other controllers.
  GroundOverlaysController({
    required StreamController<MapEvent<Object?>> stream,
  })  : _streamController = stream,
        _groundOverlayIdToController =
            <GroundOverlayId, GroundOverlayController>{};

  // A cache of [GroundOverlayController]s indexed by their [GroundOverlayId].
  final Map<GroundOverlayId, GroundOverlayController>
      _groundOverlayIdToController;

  // The stream over which ground overlays broadcast events.
  final StreamController<MapEvent<Object?>> _streamController;

  /// Returns the cache of [GroundOverlayController]s. Test only.
  @visibleForTesting
  Map<GroundOverlayId, GroundOverlayController> get groundOverlays =>
      _groundOverlayIdToController;

  /// Adds a set of [GroundOverlay] objects to the cache.
  ///
  /// Wraps each GroundOverlay into its corresponding [GroundOverlayController].
  void addGroundOverlays(Set<GroundOverlay> groundOverlaysToAdd) {
    if (groundOverlaysToAdd.isNotEmpty) {
      for (var groundOverlay in groundOverlaysToAdd) {
        _addGroundOverlay(groundOverlay);
      }
    }
  }

  void _addGroundOverlay(GroundOverlay groundOverlay) {
    final gmaps.GroundOverlayOptions groundOverlayOptions =
        _groundOverlayOptionsFromGroundOverlay(googleMap, groundOverlay);

    final gmaps.GroundOverlay gmGroundOverlay = gmaps.GroundOverlay(
      groundOverlay.imgUrl,
      gmaps.LatLngBounds(
        gmaps.LatLng(
          groundOverlay.latLngBounds.southwest.latitude,
          groundOverlay.latLngBounds.southwest.longitude,
        ),
        gmaps.LatLng(
          groundOverlay.latLngBounds.northeast.latitude,
          groundOverlay.latLngBounds.northeast.longitude,
        ),
      ),
      groundOverlayOptions,
    )..map = googleMap;

    final GroundOverlayController controller = GroundOverlayController(
      groundOverlay: gmGroundOverlay,
      consumeTapEvents: false,
      onTap: () {
        _onGroundOverlayTap(groundOverlay.groundOverlayId);
      },
    );

    _groundOverlayIdToController[groundOverlay.groundOverlayId] = controller;
  }

  /// Updates a set of [GroundOverlay] objects with new options.
  void changeGroundOverlays(Set<GroundOverlay> groundOverlaysToChange) {
    if (groundOverlaysToChange.isNotEmpty) {
      for (var groundOverlay in groundOverlaysToChange) {
        _changeGroundOverlay(groundOverlay);
      }
    }
  }

  void _changeGroundOverlay(GroundOverlay groundOverlay) {
    final GroundOverlayController? groundOverlayController =
        _groundOverlayIdToController[groundOverlay.groundOverlayId];

    if (groundOverlayController != null) {
      groundOverlayController.update(
          _groundOverlayOptionsFromGroundOverlay(googleMap, groundOverlay));
    }
  }

  /// Removes a set of [GroundOverlayId]s from the cache.
  void removeGroundOverlays(Set<GroundOverlayId> groundOverlayIdsToRemove) {
    for (var groundOverlayId in groundOverlayIdsToRemove) {
      _removeGroundOverlay(groundOverlayId);
    }
  }

  // Removes a ground overlay and its controller by its [GroundOverlayId].
  void _removeGroundOverlay(GroundOverlayId groundOverlayId) {
    final GroundOverlayController? groundOverlayController =
        _groundOverlayIdToController[groundOverlayId];
    groundOverlayController?.remove();
    _groundOverlayIdToController.remove(groundOverlayId);
  }

  // Handle internal events
  bool _onGroundOverlayTap(GroundOverlayId groundOverlayId) {
    return false; // don't have onTaps for ground overlays
    // _streamController.add(GroundOverlayTapEvent(mapId, groundOverlayId));
    // return _groundOverlayIdToController[groundOverlayId]?.consumeTapEvents ??
    //     false;
  }
}
