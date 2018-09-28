#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

if [ "$1" = 'bench' ] && [ "$2" = 'start' ]; then
	echo "setup $@"

	python -c 'import sys; print("python encoding is "+sys.stdout.encoding)'

	mkdir -p \
	sites/site1.local/locks \
	sites/site1.local/task-logs \
	sites/site1.local/public \
	sites/site1.local/public/files \
	sites/site1.local/private \
	sites/site1.local/private/files \
	sites/site1.local/private/backups

	echo "set ADMIN_PASSWORD to ***"
	sed -i "s/{{ADMIN_PASSWORD}}/${ADMIN_PASSWORD}/" sites/common_site_config.json

	echo "set DB_HOST to ${DB_HOST}"
	sed -i "s/{{DB_HOST}}/${DB_HOST}/" sites/common_site_config.json

	echo "set DB_NAME to ${DB_NAME}"
	sed -i "s/{{DB_NAME}}/${DB_NAME}/" sites/site1.local/site_config.json

	echo "set DB_PASSWORD to ***"
	sed -i "s/{{DB_PASSWORD}}/${DB_PASSWORD}/" sites/site1.local/site_config.json

	echo "set bench values"
	bench set-mariadb-host "${DB_HOST}"
	bench set-admin-password "${ADMIN_PASSWORD}"

	echo "install app erpnext"
	bench --site site1.local install-app erpnext || true

	echo "uninstall app banana"
	bench get-app banana https://github.com/bborbe/erpnext-banana-app.git --branch master
	bench --site site1.local uninstall-app banana  || true

	echo "install app seibertmedia"
	bench get-app seibertmedia ssh://git@bitbucket.apps.seibert-media.net:7999/erp/seibertmedia-app.git --branch 1.0.0
	bench --site site1.local install-app seibertmedia  || true

	echo "Run migrations for all sites in the bench"
	bench update --patch

	echo "Build JS and CSS artifacts for the bench"
	bench update --build

	echo "run $@"
fi

exec "$@"
