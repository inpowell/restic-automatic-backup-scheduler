# shellcheck shell=sh

# This is the default profile. Fill it with your desired configuration.
# Additionally, you can create and use more profiles by copying this file.

# This file (and other .env.sh files) has two purposes:
# - being sourced by systemd timers to setup the backup before running restic_backup.sh
# - being sourced in a user's shell to work directly with restic commands e.g.
#  $ source /etc/restic/default.env.sh
#  $ restic snapshots
#  Thus you don't have to provide all the arguments like
#  $ restic --repo ... --password-file ...

# shellcheck source=etc/restic/_global.env.sh
. "/etc/restic/_global.env.sh"

# Envvars below will override those in _global.env.sh if present.

export RESTIC_REPOSITORY="b2:<b2-repo-name>"   # *EDIT* fill with your repo name

# Which snapper config to back-up. Script changes directory to the latest snapshot
# and backups relative paths to pretend like it is root.
export SNAPPER_CONFIG="home" # *EDIT* choose snapper config

# Export snapper envvars
. <(snapper -c "${SNAPPER_CONFIG}" --jsonout get-config | jq -r 'to_entries|map("export SNAPPER_\(.key)=\"\(.value|tostring)\"")|.[]')
# Get latest snapshot for this config
export SNAPPER_LATEST=$(snapper -c "${SNAPPER_CONFIG}" --csvout list --columns number | tail -n 1)

export SNAPPER_SNAPSHOT="${SNAPPER_SUBVOLUME}/.snapshots/${SNAPPER_LATEST}/snapshot"
export RESTIC_BACKUP_PATH="/mnt/restic-${SNAPPER_CONFIG}" # *EDIT* Choose a mountpoint to act as base of backup
export RESTIC_BACKUP_SUBDIR="" # *EDIT* Choose which subdirectory of snapshot to backup, relative to SNAPPER_SNAPSHOT

# A tag to identify backup snapshots.
export RESTIC_BACKUP_TAG=systemd.timer

# Retention policy - How many backups to keep.
# See https://restic.readthedocs.io/en/stable/060_forget.html?highlight=month#removing-snapshots-according-to-a-policy
export RESTIC_RETENTION_HOURS=1
export RESTIC_RETENTION_DAYS=14
export RESTIC_RETENTION_WEEKS=16
export RESTIC_RETENTION_MONTHS=18
export RESTIC_RETENTION_YEARS=3

# Optional extra space-separated arguments to restic-backup.
# Example: Add two additional exclude files to the global one in RESTIC_PASSWORD_FILE.
#RESTIC_BACKUP_EXTRA_ARGS="--exclude-file /path/to/extra/exclude/file/a --exclude-file /path/to/extra/exclude/file/b"
# Example: exclude all directories that have a .git/ directory inside it.
#RESTIC_BACKUP_EXTRA_ARGS="--exclude-if-present .git"
