# Trellis on Bunny Magic Containers

This repository packages the supplied Trellis service for Bunny Magic Containers. Trellis already includes its web frontend and API, so the Dockerfile wraps the upstream image without adding another runtime or increasing its filesystem size.

## Image publication

Pushing the repository's `main` branch publishes an amd64 image through GitHub Actions:

```text
ghcr.io/<github-owner>/<repository>:latest
```

Tagged releases such as `v1.0.0` also produce matching immutable tags. Bunny currently requires `linux/amd64`; the workflow deliberately publishes only that platform.

If the GHCR package is private, connect its registry credentials in Bunny. Otherwise, set the package visibility to public after its first publication.

## Bunny Magic Containers settings

Create an application and add one container with these settings:

| Setting | Value |
| --- | --- |
| Image | `ghcr.io/<github-owner>/<repository>:latest` |
| Container port | `8477` |
| Endpoint | CDN / HTTP |
| Persistent volume mount | `/config` |
| Initial volume size | `1 GB` (expand if needed) |
| Minimum replicas | `1` |
| Maximum replicas | `1` |

Use a single replica and one region. Trellis keeps its configuration and application data in `/config`; Bunny volumes are pod-local and are not replicated between regions or replicas.

### Health checks

Configure Bunny's native checks against container port `8477`:

- **Startup:** TCP, initial delay 10 seconds, period 5 seconds, failure threshold 12
- **Readiness:** TCP, period 10 seconds, failure threshold 3
- **Liveness:** TCP, period 30 seconds, failure threshold 3

TCP checks avoid depending on an undocumented HTTP health route or extra utilities inside the compact upstream image.

## Persistent data

Mount exactly one Bunny persistent volume at `/config`. Trellis runs as UID `10001` and writes its state there. The supplied application stores addons and routing in a small JSON configuration file; it does not require a separate database container.

Bunny volumes are encrypted and persist across ordinary restarts and redeployments, but they are not automatically backed up or replicated. Keep an external backup of `/config` if the configuration is important.

## First launch

Open the Bunny endpoint after the container is ready and immediately set a password on Trellis's **Access** tab. The service starts without one, and a public CDN endpoint is internet-accessible.

## Local parity

`docker-compose.yml` builds the same image for `linux/amd64`, maps port `8477`, and stores `/config` in a named volume. It is intended for local parity testing before publishing.

## Updating Trellis

The wrapper defaults to `ghcr.io/lpierpoint/trellis:latest`. Re-running the publication workflow rebuilds against the current upstream image. For fully reproducible releases, replace that default in `Dockerfile` with a tested version tag or digest before tagging this repository.
