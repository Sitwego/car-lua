# ── Stage 1: build ───────────────────────────────────────────────────────────
# Process OSM data. The source .osm.pbf (can be 500MB+) stays in this stage
# and is never included in the final image.
FROM ghcr.io/project-osrm/osrm-backend:v6.0.0 AS builder

ARG PROFILE=car

WORKDIR /data

# Copy profile first — it changes more often than the OSM extract.
# Putting it before the .pbf means editing car.lua doesn't invalidate
# the (very expensive) .pbf COPY layer cache.
COPY ./car.lua /opt/${PROFILE}.lua

COPY ./kenya-260402-internal.osm.pbf /data/

RUN osrm-extract -p /opt/${PROFILE}.lua /data/kenya-260402-internal.osm.pbf && \
    osrm-partition /data/kenya-260402-internal.osrm && \
    osrm-customize /data/kenya-260402-internal.osrm && \
    rm -f /data/kenya-260402-internal.osm.pbf \
          /data/kenya-260402-internal.osrm.cnbg \
          /data/kenya-260402-internal.osrm.cnbg_to_ebg \
          /data/kenya-260402-internal.osrm.ebg

# ── Stage 2: runtime ─────────────────────────────────────────────────────────
# Only the processed .osrm graph files are copied — the raw .osm.pbf and
# any build-time scratch files are left behind, keeping the final image lean.
FROM ghcr.io/project-osrm/osrm-backend:v6.0.0

WORKDIR /data

COPY --from=builder /data/kenya-260402-internal.osrm* ./

EXPOSE 5000

ENTRYPOINT [ "osrm-routed", "--algorithm", "mld", "/data/kenya-260402-internal.osrm" ]
