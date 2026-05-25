# OSRM Routing Machine — Kenya

Custom OSRM (Open Source Routing Machine) setup for car routing in Kenya, tailored for Sitwego.

## What's in this repo

- **car.lua** — Custom OSRM car routing profile tuned for Kenyan roads. Includes speed profiles for local road classifications (A/B/C/D roads), left-hand driving, Nairobi traffic light penalties, and service-level restrictions.
- **Dockerfile** — Multi-stage Docker build that processes an OSM extract with the custom profile and produces a lean runtime image running `osrm-routed`.

## Prerequisites

- Docker
- A Kenya OSM extract (`.osm.pbf`) — download from [Geofabrik](https://download.geofabrik.de/africa/kenya.html) or generate an internal extract

## Usage

### Build the image

Place your `.osm.pbf` file in this directory (the filename in the Dockerfile defaults to `kenya-260402-internal.osm.pbf` — update as needed), then:

```bash
docker build -t osrm-kenya .
```

### Run the server

```bash
docker run -d -p 5000:5000 osrm-kenya
```

The OSRM HTTP API will be available at `http://localhost:5000`. Example route request:

```
http://localhost:5000/route/v1/driving/36.8219,-1.2921;36.9071,-1.1634?overview=full
```

### Updating the routing profile

Edit `car.lua` to adjust speeds, penalties, or access restrictions, then rebuild the Docker image.
