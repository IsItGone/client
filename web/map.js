class NaverMap {
  constructor(elementId, clientId, defaultLocation) {
    this.elementId = elementId;
    this.clientId = clientId;
    this.defaultLocation = defaultLocation;
    this.map = null;
    this.locationMarker = null;
    this.markers = [];
    this.polylines = [];
    this.latLngCache = new Map();
    this.isSelectionMode = false;
    this.selectedRouteId = null;
    this.zoomChangeListener = null;
  }

  async init() {
    await this.loadNaverMapsScript();
    return new Promise((resolve) => {
      naver.maps.onJSContentLoaded = () => {
        this.initMap();
        resolve();
      };
    });
  }

  loadNaverMapsScript() {
    return new Promise((resolve, reject) => {
      if (window.naver && window.naver.maps) {
        resolve();
        return;
      }
      const script = document.createElement("script");
      script.src = `https://openapi.map.naver.com/openapi/v3/maps.js?ncpClientId=${this.clientId}`;
      script.onload = resolve;
      script.onerror = reject;
      document.head.appendChild(script);
    });
  }

  initMap() {
    this.mapOptions = {
      center: new naver.maps.LatLng(this.defaultLocation.lat, this.defaultLocation.lng),
      zoom: 17,
      mapTypeId: naver.maps.MapTypeId.NORMAL,
      scaleControl: true,
      mapDataControl: false,
      scaleControlOptions: {
        position: naver.maps.Position.BOTTOM_LEFT,
      },
      logoControlOptions: {
        position: naver.maps.Position.BOTTOM_LEFT,
      },
    };
    this.map = new naver.maps.Map(this.elementId, this.mapOptions);

    naver.maps.Event.once(this.map, "init", () => {
      this.addLocationButton();
    });

    naver.maps.Event.addListener(this.map, "click", () => {
      if (this.isSelectionMode) {
        this.isSelectionMode = false;
        this.selectedRouteId = null;
        this.setVisibilityByZoom(this.map.getZoom());
      }
      this.closeDrawer();
    });
  }

  addLocationButton() {
    const locationBtnHtml = `
      <button type="button" class="btn_location" aria-pressed="false">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" class="bi bi-crosshair" viewBox="0 0 16 16">
          <path d="M8.5.5a.5.5 0 0 0-1 0v.518A7 7 0 0 0 1.018 7.5H.5a.5.5 0 0 0 0 1h.518A7 7 0 0 0 7.5 14.982v.518a.5.5 0 0 0 1 0v-.518A7 7 0 0 0 14.982 8.5h.518a.5.5 0 0 0 0-1h-.518A7 7 0 0 0 8.5 1.018zm-6.48 7A6 6 0 0 1 7.5 2.02v.48a.5.5 0 0 0 1 0v-.48a6 6 0 0 1 5.48 5.48h-.48a.5.5 0 0 0 0 1h.48a6 6 0 0 1-5.48 5.48v-.48a.5.5 0 0 0-1 0v.48A6 6 0 0 1 2.02 8.5h.48a.5.5 0 0 0 0-1zM8 10a2 2 0 1 0 0-4 2 2 0 0 0 0 4"/>
        </svg>
      </button>
    `;

    const customControl = new naver.maps.CustomControl(locationBtnHtml, {
      position: naver.maps.Position.RIGHT_BOTTOM,
    });

    customControl.setMap(this.map);

    naver.maps.Event.addDOMListener(customControl.getElement(), "click", () => {
      this.moveToCurrentLocation();
    });
  }

  moveToCurrentLocation() {
    if ("geolocation" in navigator) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const location = new naver.maps.LatLng(
            position.coords.latitude,
            position.coords.longitude
          );
          this.map.setCenter(location);
          this.updateLocationMarker(location);
        },
        (error) => {
          console.error("Error getting location:", error);
        }
      );
    } else {
      console.error("Geolocation is not supported by this browser.");
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
    const allStations = new Map();
    const markers = [];
    const polylines = [];

    this.createStationMarkers(allStations, stationsData, markers);

    for (let i = 0; i < routesData.length; i++) {
      const route = routesData[i];
      const color = `#${colorsData[i + 1].substring(2, 8)}`;

      polylines.push(
        this.createRoutePolyline(route.departureStations, color, "departure", route.id)
      );
      polylines.push(this.createRoutePolyline(route.arrivalStations, color, "arrival", route.id));
    }

    for (const polyline of polylines) {
      this.addPolylineEventListeners(polyline, allStations);
      polyline.setMap(this.map);
    }

    this.setVisibilityByZoom(this.map.getZoom());
    naver.maps.Event.addListener(this.map, "zoom_changed", () => {
      this.setVisibilityByZoom(this.map.getZoom());
    });

    this.markers = markers;
    this.polylines = polylines;
  }

  createStationMarkers(allStations, stationsData, markers) {
    const isProduction = window.location.hostname !== "localhost";
    const iconBasePath = isProduction ? "assets/assets/" : "assets/";
    const iconImageUrl = `${iconBasePath}icons/bus_station_icon.png`;

    for (const station of stationsData) {
      if (!allStations.has(station.id)) {
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
        allStations.set(station.id, marker);
        markers.push(marker);

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
    polyline.set("routeId", routeId); // 노선 ID 저장
    polyline.set(
      "stationIds",
      stations.map((station) => station.id)
    );

    return polyline;
  }

  addPolylineEventListeners(polyline, allStations) {
    naver.maps.Event.addListener(polyline, "click", (e) => {
      this.map.panTo(e.coord, { duration: 300 });
      this.map.setZoom(13, { duration: 500 });

      const routeId = polyline.get("routeId");

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
            const marker = allStations.get(stationId);
            if (marker) {
              marker.setVisible(true);
            }
          });
        }
      });

      // 선택 모드 활성화 상태 저장
      this.isSelectionMode = true;
      this.selectedRouteId = routeId;

      // 줌 레벨에 따라 선택된 노선의 마커 가시성 설정
      this.setSelectedVisibilityByZoom(this.map.getZoom());

      // 줌 변경 시 선택된 노선의 마커 가시성 업데이트
      if (!this.zoomChangeListener) {
        this.zoomChangeListener = naver.maps.Event.addListener(this.map, "zoom_changed", () => {
          if (this.isSelectionMode) {
            this.setSelectedVisibilityByZoom(this.map.getZoom());
          } else {
            this.setVisibilityByZoom(this.map.getZoom());
          }
        });
      }

      console.log("Selected route:", routeId, this.selectedRouteId);
      this.openDrawer(this.selectedRouteId, "route");
    });
  }

  setSelectedVisibilityByZoom(zoomLevel) {
    if (!this.isSelectionMode) return;

    // 선택된 노선의 마커만 줌 레벨에 따라 표시/숨김
    this.markers.forEach((marker) => {
      // 선택된 노선과 관련된 마커인지 확인
      const isRelatedToSelectedRoute = this.polylines.some(
        (p) =>
          p.get("routeId") === this.selectedRouteId &&
          p.get("stationIds").includes(marker.get("id"))
      );

      if (isRelatedToSelectedRoute) {
        const type = marker.get("type");
        const isVisible = type === "departure" ? zoomLevel >= 12 : zoomLevel >= 14;
        marker.setVisible(isVisible);
      } else {
        marker.setVisible(false);
      }
    });

    // 선택된 노선의 폴리라인도 줌 레벨에 따라 표시/숨김
    this.polylines.forEach((p) => {
      if (p.get("routeId") === this.selectedRouteId) {
        const type = p.get("type");
        const isVisible = type === "departure" ? zoomLevel >= 0 : zoomLevel >= 14;
        p.setVisible(isVisible);
      } else {
        p.setVisible(false);
      }
    });
  }

  // 줌에 따라 marker, polyline visible 설정
  setVisibilityByZoom(zoomLevel) {
    if (this.isSelectionMode) return;

    for (const marker of this.markers) {
      const isVisible = marker.get("type") === "departure" ? zoomLevel >= 12 : zoomLevel >= 14;
      marker.setVisible(isVisible);
    }

    for (const polyline of this.polylines) {
      const isVisible = polyline.get("type") === "departure" ? zoomLevel >= 0 : zoomLevel >= 14;
      polyline.setVisible(isVisible);
    }
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
    } else {
      console.error("openDrawer function is not available");
    }
  }

  closeDrawer() {
    if (typeof globalThis.closeDrawer === "function") {
      globalThis.closeDrawer();
    } else {
      console.error("closeDrawer function is not available");
    }
  }
}

async function initNaverMap(elementId, clientId) {
  const defaultLocation = { lat: 36.3553177, lng: 127.2981911 };
  window.naverMap = new NaverMap(elementId, clientId, defaultLocation);
  await window.naverMap.init();
  console.log("init naver map");
}

function drawDataToMap(routesData, stationsData, colorsData) {
  window.naverMap.drawData(routesData, stationsData, colorsData);
}

window.initNaverMap = initNaverMap;
window.drawDataToMap = drawDataToMap;

window.addEventListener("resize", () => {
  if (window.naverMap && window.naverMap.map) {
    const size = new naver.maps.Size(window.innerWidth, window.innerHeight);
    window.naverMap.map.setSize(size);
  }
});
