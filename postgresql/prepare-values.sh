#!/usr/bin/env bash
set -euo pipefail

base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
values_file="${1:-"${base_dir}/values_template.yaml"}"
output_file="${2:-"${base_dir}/values.yaml"}"

# Update these values before running this script.
# Output goes to values.yaml unless you pass a second argument.
nersc_user_id="<nersc UID>"
nersc_user_group="<nersc GID>"
app_name="postgresql"
version_tag="18"
deployment_name="psql"
db_name="<DB_name>"
db_user_password="<DB_password>"
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
