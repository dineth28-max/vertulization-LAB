# Task Notes — CCS3308 Assignment 1

Internal working notes for building/submitting this assignment. Not part of the
graded deliverables (the grader only cares about the files listed below), but
keeping this here so the process is documented while developing.

## What the assignment requires

- A Docker app with **>= 2 services**, each in its own container, each on its own port,
  able to talk to each other, and **>= 1 service with a persistent named volume**.
- Submit to a **public GitHub repo named `<registration_number>`**:
  1. `prepare-app.sh` — build images, create network + named volumes, write configs.
  2. `start-app.sh` — start containers with `--restart` policy, print the access URL.
  3. `stop-app.sh` — stop containers, **keep volumes/state**.
  4. `remove-app.sh` — tear down everything prepare-app.sh created.
  5. `docker-compose.yaml` — optional, included anyway as the Compose equivalent.
  6. `README.md` — full documentation (requirements, architecture, network/volume
     details, container config, container list, instructions, example workflow).

## App chosen

**Notes App**: a small Flask web service (`web`) backed by PostgreSQL (`db`).
- `web`: custom-built image (Dockerfile + Flask + psycopg2), listens on host port
  **5000**, talks to `db` over the `notesapp-net` bridge network using the service
  name `db` as hostname.
- `db`: official `postgres:16-alpine` image, listens on host port **5432**, data
  persisted in named volume `notesapp_db_data` so notes survive container restarts
  and recreation (as long as the volume isn't removed).

This satisfies: two services, separate containers, separate ports, inter-service
communication (web -> db via Postgres protocol on the custom network), and a
persistent volume on the `db` service.

## Design decisions / why

- Used a **custom bridge network** (`notesapp-net`) instead of default bridge so the
  containers get DNS-based service discovery (`db` resolves to the db container IP).
- `stop-app.sh` uses `docker stop` (not `rm`), so the containers + volume are
  preserved and `start-app.sh` can just `docker start` them again without losing data.
- `start-app.sh` is idempotent: if containers already exist (just stopped), it starts
  them; if not, it creates+runs them. This avoids "container name already in use"
  errors on repeated runs.
- `remove-app.sh` removes containers, network, volume, and the custom image — a full
  reset back to a clean slate, matching "remove all resources created by
  prepare-app.sh".
- Postgres credentials/config are passed as environment variables in `start-app.sh`
  rather than baked into the image, so they're easy to see/change without rebuilding.
- Added a `docker-compose.yaml` as the optional declarative equivalent of the four
  scripts, for convenience / cross-checking, since the assignment allows it.

## Submission checklist

- [ ] Create public GitHub repo named `<your_registration_number>`.
- [ ] Push all files (scripts, Dockerfile, app code, docker-compose.yaml, README.md).
- [ ] Test the full flow on a clean machine/VM: prepare -> start -> use in browser ->
      stop -> start again (data still there) -> remove.
- [ ] Make sure scripts are executable (`chmod +x *.sh`) and use `#!/usr/bin/env bash`.
- [ ] Fill in registration number / name in README.md before submitting.
- [ ] Submit repo link via LMS.
