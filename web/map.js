class NaverMap {
  constructor(elementId) {
    this.elementId = elementId;
    this.defaultLocation = { lat: 36.3553177, lng: 127.2981911 };
    this.map = null;
    this.locationMarker = null;
    this.markers = [];
    this.polylines = [];
    this.allStations = new Map();
    this.latLngCache = new Map();
    this.isSelectionMode = false;
    this.selectedRouteId = null;
  }

  async init() {
    return new Promise((resolve) => {
      naver.maps.onJSContentLoaded = () => {
        this.initMap();
        resolve();
      };
    });
  }

  initMap() {
    const mapOptions = {
      center: new naver.maps.LatLng(this.defaultLocation.lat, this.defaultLocation.lng),
      zoom: 17,
      mapTypeId: naver.maps.MapTypeId.NORMAL,
      scaleControl: false,
      mapDataControl: false,
      tileTransition: false,
      scaleControlOptions: {
        position: naver.maps.Position.BOTTOM_LEFT,
      },
      logoControlOptions: {
        position: naver.maps.Position.BOTTOM_LEFT,
      },
      minZoom: 10,
      maxZoom: 18,
    };

    this.map = new naver.maps.Map(this.elementId, mapOptions);
    this.registerMapEvents();

    naver.maps.Event.once(this.map, "init", () => {
      this.addLocationButton();
    });
  }

  registerMapEvents() {
    naver.maps.Event.addListener(this.map, "click", () => {
      if (this.isSelectionMode) {
        this.isSelectionMode = false;
        this.selectedRouteId = null;
        this.setVisibilityByZoom(this.map.getZoom());
      }
      if (typeof globalThis.closeDrawer === "function") {
        globalThis.closeDrawer();
      }
    });

    let zoomTimeout;
    naver.maps.Event.addListener(this.map, "zoom_changed", () => {
      clearTimeout(zoomTimeout);
      zoomTimeout = setTimeout(() => {
        const zoomLevel = this.map.getZoom();
        if (this.isSelectionMode) {
          this.setSelectedVisibilityByZoom(zoomLevel);
        } else {
          this.setVisibilityByZoom(zoomLevel);
        }
      }, 100);
    });
  }
  addLocationButton() {
    const locationBtnHtml = `
    <button type="button" class="btn_location" aria-label="현재 위치 찾기" aria-pressed="false">
      <img src="./icons/svg/crosshair.svg" alt="현재 위치 아이콘" width="24" height="24" />
    </button>
    `;

    const control = new naver.maps.CustomControl(locationBtnHtml, {
      position: naver.maps.Position.RIGHT_BOTTOM,
    });

    control.setMap(this.map);
    naver.maps.Event.addDOMListener(control.getElement(), "click", () => {
      this.moveToCurrentLocation();
    });
  }
  moveToCurrentLocation() {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          const loc = new naver.maps.LatLng(pos.coords.latitude, pos.coords.longitude);
          this.map.setCenter(loc);
          this.updateLocationMarker(loc);
        },
        (err) => {
          console.error("Geolocation error:", err);
        }
      );
    } else {
      console.error("Geolocation not supported.");
    }
  }

  updateLocationMarker(location) {
    if (this.locationMarker) {
      this.locationMarker.setPosition(location);
    } else {
      this.locationMarker = new naver.maps.Marker({
        position: location,
        map: this.map,
      });
    }
  }

  drawData(routesData, stationsData, colorsData) {
    this.allStations.clear();
    this.markers = [];
    this.polylines = [];

    this.createStationMarkers(stationsData);

    for (let i = 0; i < routesData.length; i++) {
      const route = routesData[i];
      const color = `#${colorsData[i + 1].substring(2, 8)}`;
      this.polylines.push(
        this.createRoutePolyline(route.departureStations, color, "departure", route.id)
      );
      this.polylines.push(
        this.createRoutePolyline(route.arrivalStations, color, "arrival", route.id)
      );
    }

    for (const polyline of this.polylines) {
      this.addPolylineEventListeners(polyline);
      polyline.setMap(this.map);
    }
  }

  createStationMarkers(stationsData) {
    const isProduction = window.location.hostname !== "localhost";
    const iconBasePath = isProduction ? "assets/assets/" : "assets/";
    const iconImageUrl = `${iconBasePath}icons/bus_station_icon.png`;

    for (const station of stationsData) {
      if (!this.allStations.has(station.id)) {
        const marker = new naver.maps.Marker({
          position: this.getLatLng(station.latitude, station.longitude),
          icon: {
            url: iconImageUrl,
            scaledSize: new naver.maps.Size(20, 28),
          },
          map: this.map,
        });
        marker.set("id", station.id);
        marker.set("type", station.isDeparture ? "departure" : "arrival");
        this.allStations.set(station.id, marker);
        this.markers.push(marker);

        naver.maps.Event.addListener(marker, "click", () => {
          this.map.panTo(marker.getPosition(), { duration: 300 });
          this.openDrawer(marker.get("id"), "station");
          naver.maps.Event.once(this.map, "idle", () => {
            if (this.map.getZoom() < 17) this.map.setZoom(17, { duration: 200 });
          });
        });
      }
    }
  }

  createRoutePolyline(stations, color, type, routeId) {
    const path = stations.map(({ latitude, longitude }) => this.getLatLng(latitude, longitude));
    const polyline = new naver.maps.Polyline({
      path,
      strokeColor: color,
      strokeOpacity: 0.8,
      strokeWeight: 8,
      strokeLineCap: "round",
      strokeLineJoin: "round",
      zIndex: 2,
      clickable: true,
    });
    polyline.set("type", type);
    polyline.set("routeId", routeId);
    polyline.set(
      "stationIds",
      stations.map((s) => s.id)
    );
    return polyline;
  }

  addPolylineEventListeners(polyline) {
    naver.maps.Event.addListener(polyline, "click", (e) => {
      const routeId = polyline.get("routeId");
      this.selectRouteById(routeId, e.coord);
    });
  }
  selectRouteById(routeId, coord) {
    // 모든 폴리라인과 마커 숨기기
    this.polylines.forEach((p) => p.setVisible(false));
    this.markers.forEach((m) => m.setVisible(false));

    // 같은 노선의 승차/하차 폴리라인 모두 표시
    this.polylines.forEach((p) => {
      if (p.get("routeId") === routeId) {
        p.setVisible(true);

        // 선택된 폴리라인의 관련 마커 표시
        const stationIds = p.get("stationIds");
        stationIds.forEach((stationId) => {
          const marker = this.allStations.get(stationId);
          if (marker) marker.setVisible(true);
        });
      }
    });

    const target = coord
      ? coord
      : this.getLatLng(this.defaultLocation.lat, this.defaultLocation.lng);
    this.map.panTo(target, { duration: 300 });
    this.map.setZoom(12, { duration: 500 });

    // 선택 모드 활성화 상태 저장
    this.isSelectionMode = true;
    this.selectedRouteId = routeId;

    // 줌 레벨에 따라 선택된 노선의 마커 가시성 설정
    this.setSelectedVisibilityByZoom(this.map.getZoom());
    this.openDrawer(routeId, "route");
  }

  setSelectedVisibilityByZoom(zoomLevel) {
    if (!this.isSelectionMode) return;

    // 선택된 노선의 마커만 줌 레벨에 따라 표시/숨김
    this.markers.forEach((marker) => {
      // 선택된 노선과 관련된 마커인지 확인
      const isRelated = this.polylines.some(
        (p) =>
          p.get("routeId") === this.selectedRouteId &&
          p.get("stationIds").includes(marker.get("id"))
      );
      if (isRelated) {
        const type = marker.get("type");
        marker.setVisible(type === "departure" ? zoomLevel >= 12 : zoomLevel >= 14);
      } else {
        marker.setVisible(false);
      }
    });

    // 선택된 노선의 폴리라인도 줌 레벨에 따라 표시/숨김
    this.polylines.forEach((p) => {
      const type = p.get("type");
      const visible =
        p.get("routeId") === this.selectedRouteId && (type === "departure" || zoomLevel >= 14);
      p.setVisible(visible);
    });
  }

  // 줌에 따라 marker, polyline visible 설정
  setVisibilityByZoom(zoomLevel) {
    if (this.isSelectionMode) return;
    this.markers.forEach((m) => {
      const type = m.get("type");
      m.setVisible(type === "departure" ? zoomLevel >= 12 : zoomLevel >= 14);
    });
    this.polylines.forEach((p) => {
      const type = p.get("type");
      p.setVisible(type === "departure" ? zoomLevel >= 0 : zoomLevel >= 14);
    });
  }

  getLatLng(lat, lng) {
    const key = `${lat},${lng}`;
    if (!this.latLngCache.has(key)) {
      this.latLngCache.set(key, new naver.maps.LatLng(lat, lng));
    }
    return this.latLngCache.get(key);
  }

  openDrawer(id, type) {
    if (typeof globalThis.openDrawer === "function") {
      globalThis.openDrawer(id, type);
    }
  }

  closeDrawer() {
    if (typeof globalThis.closeDrawer === "function") {
      globalThis.closeDrawer();
    }
  }
}

window.initializeNaverMap = async function (elementId) {
  const container = document.getElementById(elementId);
  if (!container) {
    console.warn(`[NaverMap] Element #${elementId} not found`);
    return Promise.reject("Map container not found");
  }

  // 이미 지도 인스턴스가 존재하면 재사용
  if (window.naverMap && window.naverMap.map) {
    if (window.naverMap.container && container !== window.naverMap.container) {
      container.appendChild(window.naverMap.container);
    }
    return Promise.resolve(true);
  }

  const instance = new NaverMap(elementId);
  return instance.init().then(() => {
    window.naverMap = instance;
    window.naverMap.container = container;
    return true;
  });
};

window.selectRoute = function (routeId) {
  if (window.naverMap && typeof window.naverMap.selectRouteById === "function") {
    window.naverMap.selectRouteById(routeId);
  }
};

window.addEventListener("resize", () => {
  if (window.naverMap && window.naverMap.map) {
    const size = new naver.maps.Size(window.innerWidth, window.innerHeight);
    window.naverMap.map.setSize(size);
  }
});
