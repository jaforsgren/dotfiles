# Azurite cheatsheet

Local Azure Storage emulator, running in Docker (`azurite-blobstorage`, ports
10000=blob, 10001=queue, 10002=table).

Connection string lives in `.env` as `AZURITE_CONNECTION_STRING` and is
exported by `loadenv` on shell start.

## Connect

- `azconn` - point the `az` CLI at local Azurite for this shell (exports
  `AZURE_STORAGE_CONNECTION_STRING`), so every `az storage ...` command below
  works without passing `--connection-string` each time.

## Containers

- `az storage container list --output table` - list containers
- `az storage container create --name <name>` - create a container
- `az storage container delete --name <name>` - delete a container

## Blobs

- `az storage blob list --container-name <container> --output table` - list blobs
- `az storage blob upload --container-name <container> --name <blob> --file <path>` - upload
- `az storage blob download --container-name <container> --name <blob> --file <path>` - download
- `az storage blob delete --container-name <container> --name <blob>` - delete a blob
- `az storage blob show --container-name <container> --name <blob>` - blob metadata/properties

## GUI

Microsoft Azure Storage Explorer is installed (`microsoft-azure-storage-explorer`
brew cask). Attach to Azurite via: Attach to a resource -> Storage account or
service -> Connection string -> paste `$AZURITE_CONNECTION_STRING`.
