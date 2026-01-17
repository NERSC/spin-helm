#!/usr/bin/env bash
set -euo pipefail

base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
values_file="${1:-"${base_dir}/values.yaml"}"
output_file="${2:-"${base_dir}/values.rendered.yaml"}"

# Update these values before running this script.
# Output goes to values.rendered.yaml unless you pass a second argument.
nersc_user_id="75369"
nersc_user_group="75369"
app_name="postgresql"
version_tag="17"
deployment_name="pqdb"
db_name="science"
db_user_password="pwialks;d"
db_user_name="user"
pvc_size="10Gi"

tmp_file="$(mktemp)"
sed \
  -e "s|{{nersc_user_id}}|${nersc_user_id}|g" \
  -e "s|{{nersc_user_group}}|${nersc_user_group}|g" \
  -e "s|{{app_name}}|${app_name}|g" \
  -e "s|{{version_tag}}|${version_tag}|g" \
  -e "s|{{deployment_name}}|${deployment_name}|g" \
  -e "s|{{db_name}}|${db_name}|g" \
  -e "s|{{db_user_password}}|${db_user_password}|g" \
  -e "s|{{db_user_name}}|${db_user_name}|g" \
  -e "s|{{pvc_size}}|${pvc_size}|g" \
  "$values_file" > "$tmp_file"
mv "$tmp_file" "$output_file"
