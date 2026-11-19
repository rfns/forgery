#!/usr/bin/env bash
#
# Exports the release artifacts: one for IRIS and one for Caché.
#
# Two files are needed because the sources use IRIS-only constructs. %Any has no
# counterpart in Caché, and no export flag rewrites it: /exportversion only
# changes the format of the XML envelope, never the class definitions inside it.
# The Caché artifact is therefore exported from sources that bin/iris-bc.sh has
# already rewritten.
#
# Usage: bin/export-xml.sh <version> [output-dir]
#   bin/export-xml.sh v2.1.0 dist

set -euo pipefail

VERSION="${1:-}"
OUTPUT_DIR="${2:-dist}"
IMAGE="${IRIS_IMAGE:-docker.io/intersystemsdc/iris-community:latest}"

if [ -z "$VERSION" ]; then
  echo "export-xml.sh: usage: bin/export-xml.sh <version> [output-dir]" >&2
  exit 2
fi

# The presence of the binary says nothing: a machine can ship the docker CLI
# with no daemon behind it, which is common where podman is the real engine.
ENGINE="${CONTAINER_ENGINE:-}"
if [ -z "$ENGINE" ]; then
  for candidate in docker podman; do
    if command -v "$candidate" > /dev/null 2>&1 && "$candidate" info > /dev/null 2>&1; then
      ENGINE="$candidate"
      break
    fi
  done
fi

if [ -z "$ENGINE" ]; then
  echo "export-xml.sh: no working container engine was found. Set CONTAINER_ENGINE to override." >&2
  exit 1
fi

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
CONTAINER="forgery-export-$$"

cleanup() {
  "$ENGINE" rm -f "$CONTAINER" > /dev/null 2>&1 || true
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

# The Caché flavour is exported from a rewritten copy, so the checkout is left
# untouched and both flavours can be produced in a single run.
cp -r "$REPO_DIR/cls" "$WORK_DIR/cls"
mkdir -p "$WORK_DIR/cache"
cp -r "$REPO_DIR/cls" "$WORK_DIR/cache/cls"
"$REPO_DIR/bin/iris-bc.sh" "$WORK_DIR/cache"

# mktemp -d creates the directory as 700, which the unprivileged user inside the
# container cannot traverse, and IRIS reports it as an invalid directory.
chmod -R a+rX "$WORK_DIR"

echo "export-xml.sh: starting $IMAGE ..."

# The image's post-start hook fails on recent builds and takes the instance down
# with it, so IRIS is started by hand and the container is kept alive.
"$ENGINE" run -d -t --name "$CONTAINER" \
  -v "$WORK_DIR:/sources:z" \
  --entrypoint /bin/bash \
  "$IMAGE" -c "iris start IRIS && sleep infinity" > /dev/null

ready=0
for _ in $(seq 1 90); do
  if "$ENGINE" exec "$CONTAINER" iris list 2> /dev/null | grep -q running; then
    ready=1
    break
  fi
  sleep 2
done

if [ "$ready" -ne 1 ]; then
  echo "export-xml.sh: the instance did not come up in time." >&2
  "$ENGINE" logs "$CONTAINER" 2>&1 | tail -20 >&2
  exit 1
fi

export_flavour() {
  local sources="$1"
  local artifact="$2"
  local namespace="$3"

  echo "export-xml.sh: exporting $artifact ..."

  "$ENGINE" exec -i "$CONTAINER" iris session IRIS -U "%SYS" <<SEOF
  set sc = ##class(%SYS.Namespace).Exists("$namespace")
  if 'sc {
    set properties("Globals") = "USER"
    set properties("Routines") = "USER"
    do ##class(Config.Namespaces).Create("$namespace", .properties)
  }
  halt
SEOF

  "$ENGINE" exec -i "$CONTAINER" iris session IRIS -U "$namespace" <<SEOF
  set sc = \$System.OBJ.LoadDir("$sources", "ck", , 1)
  if 'sc { do \$System.OBJ.DisplayError(sc)  do \$System.Process.Terminate(, 1) }

  set sc = \$System.OBJ.Export("Forgery.*.cls", "/tmp/$artifact", "/exportversion=2016.2")
  if 'sc { do \$System.OBJ.DisplayError(sc)  do \$System.Process.Terminate(, 1) }

  halt
SEOF

  "$ENGINE" cp "$CONTAINER:/tmp/$artifact" "$OUTPUT_DIR/$artifact"

  # A silently empty export is the failure mode worth guarding against: a wrong
  # item list still produces a valid, useless XML with no classes in it.
  local classes
  classes=$(grep -c '<Class name=' "$OUTPUT_DIR/$artifact" || true)
  if [ "$classes" -lt 1 ]; then
    echo "export-xml.sh: $artifact carries no classes." >&2
    exit 1
  fi

  ( cd "$OUTPUT_DIR" && sha1sum "$artifact" | cut -f 1 -d " " > "${artifact%.xml}.sha1" )
  echo "export-xml.sh: wrote $OUTPUT_DIR/$artifact ($classes classes)."
}

mkdir -p "$OUTPUT_DIR"

# Separate namespaces so the rewritten classes never overwrite the originals.
export_flavour "/sources/cls" "forgery-${VERSION}-iris.xml" "IRISFLAVOUR"
export_flavour "/sources/cache/cls" "forgery-${VERSION}.xml" "CACHEFLAVOUR"

# The whole point of the second artifact: it must not mention a type Caché does
# not have, or consumers discover it only at compile time, inside their own CI.
if grep -q "%Any" "$OUTPUT_DIR/forgery-${VERSION}.xml"; then
  echo "export-xml.sh: the Caché artifact still mentions %Any." >&2
  exit 1
fi

echo "export-xml.sh: done."
