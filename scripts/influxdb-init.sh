#!/bin/bash
# Espera a que InfluxDB esté listo y crea el bucket adicional garden_events.
# El bucket garden_telemetry se crea automáticamente por las env vars de InfluxDB.

set -e

INFLUX_HOST="http://localhost:8086"
MAX_RETRIES=30

echo "Esperando a que InfluxDB esté disponible..."
for i in $(seq 1 $MAX_RETRIES); do
  if influx ping --host "$INFLUX_HOST" 2>/dev/null; then
    echo "InfluxDB listo."
    break
  fi
  if [ "$i" -eq "$MAX_RETRIES" ]; then
    echo "ERROR: InfluxDB no respondió tras $MAX_RETRIES intentos."
    exit 1
  fi
  sleep 2
done

# Crear bucket garden_events (retención 365 días = 31536000s)
if influx bucket list --host "$INFLUX_HOST" --org "$DOCKER_INFLUXDB_INIT_ORG" \
    --token "$DOCKER_INFLUXDB_INIT_ADMIN_TOKEN" | grep -q "garden_events"; then
  echo "Bucket garden_events ya existe, skip."
else
  influx bucket create \
    --host "$INFLUX_HOST" \
    --org "$DOCKER_INFLUXDB_INIT_ORG" \
    --token "$DOCKER_INFLUXDB_INIT_ADMIN_TOKEN" \
    --name garden_events \
    --retention 31536000s \
    --description "Eventos de riego y alertas (retención 1 año)"
  echo "Bucket garden_events creado."
fi
