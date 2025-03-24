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

  drawRoutes(routesData, colorsData) {
    const allStations = new Map();
    const markers = [];
    const polylines = [];

    for (let i = 0; i < routesData.length; i++) {
      const route = routesData[i];
      const color = `#${colorsData[i + 1].substring(2, 8)}`;

      this.createStationMarkers(route.departureStations, allStations, markers, "departure");
      this.createStationMarkers(route.arrivalStations, allStations, markers, "arrival");

      polylines.push(this.createRoutePolyline(route.departureStations, color, "departure"));
      polylines.push(this.createRoutePolyline(route.arrivalStations, color, "arrival"));
    }

    for (const polyline of polylines) {
      this.addPolylineEventListeners(polyline);
      polyline.setMap(this.map);
    }

    this.setVisibilityByZoom(this.map.getZoom());
    naver.maps.Event.addListener(this.map, "zoom_changed", () => {
      this.setVisibilityByZoom(this.map.getZoom());
    });

    this.markers = markers;
    this.polylines = polylines;
  }

  createStationMarkers(stations, allStations, markers, type) {
    const isProduction = window.location.hostname !== "localhost";
    const iconBasePath = isProduction ? "assets/assets/" : "assets/";
    const iconImageUrl = `${iconBasePath}icons/bus_station_icon.png`;

    for (const station of stations) {
      if (!allStations.has(station.id)) {
        allStations.set(station.id, station);
        const marker = new naver.maps.Marker({
          position: this.getLatLng(station.latitude, station.longitude),
          icon: {
            url: iconImageUrl,
            scaledSize: new naver.maps.Size(20, 28),
          },
          map: this.map,
        });
        marker.set("id", station.id);
        marker.set("name", station.name);
        marker.set("type", type);
        markers.push(marker);

        naver.maps.Event.addListener(marker, "click", () => {
          console.log("Marker clicked:", marker.get("id"));
          this.map.panTo(marker.getPosition(), { duration: 300 });
          this.openDrawer(marker.get("id"));
          naver.maps.Event.once(this.map, "idle", () => {
            if (this.map.getZoom() < 17) this.map.setZoom(17, { duration: 200 });
          });
        });
      }
    }
  }

  createRoutePolyline(stations, color, type) {
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
    return polyline;
  }

  addPolylineEventListeners(polyline) {
    naver.maps.Event.addListener(polyline, "mousedown", () =>
      polyline.setOptions({ strokeWeight: 10 })
    );
    naver.maps.Event.addListener(polyline, "mouseup", () =>
      polyline.setOptions({ strokeWeight: 6 })
    );
    naver.maps.Event.addListener(polyline, "click", () => alert("polyline click"));
  }

  // 줌에 따라 marker, polyline visible 설정
  setVisibilityByZoom(zoomLevel) {
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

  openDrawer(id) {
    if (typeof globalThis.openDrawer === "function") {
      globalThis.openDrawer(id);
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
}

function drawRoutesToMap(routesData, colorsData) {
  window.naverMap.drawRoutes(routesData, colorsData);
}

window.initNaverMap = initNaverMap;
window.drawRoutesToMap = drawRoutesToMap;

window.addEventListener("resize", () => {
  if (window.naverMap && window.naverMap.map) {
    const size = new naver.maps.Size(window.innerWidth, window.innerHeight);
    window.naverMap.map.setSize(size);
  }
});
