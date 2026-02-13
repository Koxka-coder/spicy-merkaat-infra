# Spicy Merkaat Infrastructure

Docker-based infrastructure for the Spicy Merkaat project, providing MQTT messaging, time-series data storage, relational database, API backend, and frontend services.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [First Run Instructions](#first-run-instructions)
- [Services](#services)
- [Configuration](#configuration)
- [Management Commands](#management-commands)
- [Backup and Deployment](#backup-and-deployment)
- [Troubleshooting](#troubleshooting)

## Overview

This repository contains the Docker Compose configuration and related files for running the Spicy Merkaat infrastructure stack. The stack includes:

- **Mosquitto**: MQTT broker for IoT messaging
- **PostGIS**: PostgreSQL database with spatial extensions
- **InfluxDB**: Time-series database for metrics and sensor data
- **API**: Backend API service
- **Frontend**: Web application frontend

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Frontend                              │
│                    (Web Application)                         │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                         API                                  │
│                   (Backend Service)                          │
└──┬────────────┬────────────┬─────────────────────────────┬──┘
   │            │            │                             │
┌──▼───┐  ┌────▼────┐  ┌────▼─────┐                 ┌─────▼────┐
│ MQTT │  │PostGIS  │  │ InfluxDB │                 │   ...    │
│Broker│  │Database │  │Time-Series│                 │          │
└──────┘  └─────────┘  └──────────┘                 └──────────┘
```

## Prerequisites

Before you begin, ensure you have the following installed on your system:

- **Docker** (version 20.10 or higher)
  - [Installation guide](https://docs.docker.com/engine/install/)
- **Docker Compose** (version 2.0 or higher)
  - [Installation guide](https://docs.docker.com/compose/install/)
- **Git** (for cloning the repository)
- At least **4GB of available RAM**
- At least **10GB of available disk space**

### Verify Installation

```bash
docker --version
docker compose version
```

## Initial Setup

### 1. Clone the Repository

```bash
git clone https://github.com/Koxka-coder/spicy-merkaat-infra.git
cd spicy-merkaat-infra
```

### 2. Create Environment File

Copy the example environment file and configure it for your environment:

```bash
cp .env.example .env
```

Edit the `.env` file with your preferred text editor and set the required variables:

```bash
nano .env  # or vim, code, etc.
```

**Important environment variables to configure:**

- `POSTGRES_USER`: PostgreSQL username (default: `postgres`)
- `POSTGRES_PASSWORD`: PostgreSQL password (**change this!**)
- `POSTGRES_DB`: PostgreSQL database name (default: `spicymerkaat`)
- `INFLUXDB_ADMIN_USER`: InfluxDB admin username
- `INFLUXDB_ADMIN_PASSWORD`: InfluxDB admin password (**change this!**)
- `INFLUXDB_DB`: InfluxDB database name
- `MOSQUITTO_USER`: MQTT broker username
- `MOSQUITTO_PASSWORD`: MQTT broker password (**change this!**)
- `API_PORT`: Port for the API service (default: `3000`)
- `FRONTEND_PORT`: Port for the frontend service (default: `8080`)

### 3. Create Required Directories

Ensure all configuration and data directories exist:

```bash
mkdir -p config/influxdb
mkdir -p data/{postgres,influxdb,mosquitto}
mkdir -p logs
```

### 4. Review Configuration Files

Check and customize the configuration files if needed:

- **`config/mosquitto.conf`**: Mosquitto MQTT broker configuration
- **`config/postgres/init.sql`**: PostgreSQL initialization script
- **`config/influxdb/`**: InfluxDB configuration files

## First Run Instructions

### Step 1: Build the Services

Build all Docker images:

```bash
docker compose build
```

This may take several minutes on the first run.

### Step 2: Start the Infrastructure

Start all services in detached mode:

```bash
docker compose up -d
```

### Step 3: Verify Services are Running

Check the status of all services:

```bash
docker compose ps
```

All services should show as "Up" or "healthy".

### Step 4: Check Logs

View logs to ensure services started correctly:

```bash
# View all logs
docker compose logs

# View logs for a specific service
docker compose logs mosquitto
docker compose logs postgis
docker compose logs influxdb
docker compose logs api
docker compose logs frontend

# Follow logs in real-time
docker compose logs -f
```

### Step 5: Access the Services

Once all services are running, you can access them at:

- **Frontend**: http://localhost:8080 (or the port specified in `FRONTEND_PORT`)
- **API**: http://localhost:3000 (or the port specified in `API_PORT`)
- **InfluxDB Admin UI**: http://localhost:8086
- **MQTT Broker**: localhost:1883 (MQTT) and localhost:9001 (WebSocket)
- **PostgreSQL**: localhost:5432

### Step 6: Initial Database Setup

The PostgreSQL database will be initialized automatically using the script in `config/postgres/init.sql`. You can verify the setup:

```bash
docker compose exec postgis psql -U postgres -d spicymerkaat -c "\dt"
```

## Services

### Mosquitto (MQTT Broker)

Eclipse Mosquitto is a lightweight MQTT broker for IoT messaging.

- **Port**: 1883 (MQTT), 9001 (WebSocket)
- **Configuration**: `config/mosquitto.conf`
- **Data**: Persisted in `data/mosquitto`

**Testing MQTT Connection:**

```bash
# Subscribe to a topic
docker compose exec mosquitto mosquitto_sub -h localhost -t "test/topic" -u ${MOSQUITTO_USER} -P ${MOSQUITTO_PASSWORD}

# Publish a message (in another terminal)
docker compose exec mosquitto mosquitto_pub -h localhost -t "test/topic" -m "Hello MQTT" -u ${MOSQUITTO_USER} -P ${MOSQUITTO_PASSWORD}
```

### PostGIS (PostgreSQL + Spatial Extensions)

PostgreSQL database with PostGIS extensions for spatial data.

- **Port**: 5432
- **Configuration**: `config/postgres/init.sql`
- **Data**: Persisted in `data/postgres`

**Connecting to the Database:**

```bash
docker compose exec postgis psql -U postgres -d spicymerkaat
```

### InfluxDB (Time-Series Database)

InfluxDB for storing time-series metrics and sensor data.

- **Port**: 8086
- **Configuration**: `config/influxdb/`
- **Data**: Persisted in `data/influxdb`

**Accessing InfluxDB CLI:**

```bash
docker compose exec influxdb influx
```

### API (Backend Service)

The backend API service that connects all components.

- **Port**: Configured via `API_PORT` (default: 3000)
- **Health Check**: http://localhost:3000/health

### Frontend (Web Application)

The web application frontend.

- **Port**: Configured via `FRONTEND_PORT` (default: 8080)
- **Access**: http://localhost:8080

## Configuration

### Mosquitto Configuration

Edit `config/mosquitto.conf` to customize MQTT broker settings:

- Authentication settings
- Listener ports
- Persistence options
- Logging levels

### PostgreSQL Initialization

The `config/postgres/init.sql` script runs automatically on first startup. Add your schema definitions, initial data, or user creation statements here.

### InfluxDB Configuration

Place any custom InfluxDB configuration files in `config/influxdb/`.

## Management Commands

### Starting Services

```bash
# Start all services
docker compose up -d

# Start specific services
docker compose up -d mosquitto postgis
```

### Stopping Services

```bash
# Stop all services
docker compose down

# Stop but keep volumes (preserve data)
docker compose stop
```

### Restarting Services

```bash
# Restart all services
docker compose restart

# Restart a specific service
docker compose restart api
```

### Viewing Logs

```bash
# All services
docker compose logs -f

# Specific service with tail
docker compose logs -f --tail=100 api
```

### Updating Services

```bash
# Pull latest images
docker compose pull

# Rebuild and restart
docker compose up -d --build
```

### Removing Everything

```bash
# Stop and remove containers, networks
docker compose down

# Stop and remove containers, networks, volumes (⚠️ deletes all data!)
docker compose down -v
```

## Backup and Deployment

### PostgreSQL Backup

Use the provided backup script:

```bash
./scripts/backup_pg.sh
```

This script creates a timestamped backup of the PostgreSQL database in the `backups/` directory.

**Manual backup:**

```bash
docker compose exec postgis pg_dump -U postgres spicymerkaat > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Restore PostgreSQL Backup

```bash
docker compose exec -T postgis psql -U postgres spicymerkaat < backup_file.sql
```

### Deployment

Use the deployment script for automated deployment:

```bash
./scripts/deploy.sh
```

This script typically handles:
- Pulling latest changes
- Building images
- Running database migrations
- Restarting services with zero downtime

## Troubleshooting

### Services Won't Start

**Check logs:**
```bash
docker compose logs
```

**Common issues:**
- Port conflicts: Ensure ports 1883, 5432, 8086, 3000, and 8080 are not in use
- Insufficient resources: Check Docker resource limits
- Permission issues: Ensure data directories have correct permissions

### Cannot Connect to Database

**Verify the service is running:**
```bash
docker compose ps postgis
```

**Check connection from within the network:**
```bash
docker compose exec api ping postgis
```

**Verify credentials:**
Ensure the `.env` file has correct database credentials.

### MQTT Connection Issues

**Test broker connectivity:**
```bash
docker compose exec mosquitto netstat -tlnp | grep 1883
```

**Check Mosquitto logs:**
```bash
docker compose logs mosquitto
```

### InfluxDB Not Accessible

**Verify service is running:**
```bash
docker compose ps influxdb
curl http://localhost:8086/health
```

### Data Not Persisting

**Check volume mounts:**
```bash
docker compose config | grep volumes -A 5
```

**Verify volumes exist:**
```bash
docker volume ls
```

### Performance Issues

**Check resource usage:**
```bash
docker stats
```

**Increase Docker resources:**
- Adjust Docker Desktop settings (on Mac/Windows)
- Modify compose file resource limits

### Reset Everything

If you need to start fresh:

```bash
# Stop all services
docker compose down -v

# Remove all data
rm -rf data/*

# Restart
docker compose up -d
```

## Support

For issues and questions:
- Check the [GitHub Issues](https://github.com/Koxka-coder/spicy-merkaat-infra/issues)
- Review Docker Compose logs: `docker compose logs`

## License

[Add your license information here]
