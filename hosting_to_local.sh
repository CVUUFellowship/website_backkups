#!/bin/bash

if [ "$#" != "1" ]; then
	echo "usage: $0 <config_file>"
	exit 1
fi

set -x
set -e

config_file=$1
. ${config_file}

set +x

err_exit=0
if [ "${LOCAL_DIR}" = "" ]; then
	echo "LOCAL_DIR not set in ${config_file}"
	err_exit=1
elif [ ! -d "${LOCAL_DIR}" ]; then
	echo "LOCAL_DIR=${LOCAL_DIR} is not a directory"
	err_exit=1
fi

if [ "${DB_HOST}" = "" ]; then
	echo "DB_HOST not set in ${config_file}"
	err_exit=1
fi

if [ "${DB_NAME}" = "" ]; then
	echo "DB_NAME not set in ${config_file}"
	err_exit=1
fi
if [ "${DB_PW}" = "" ]; then
	echo "DB_PW not set in ${config_file}"
	err_exit=1
fi
if [ "${DB_USER}" = "" ]; then
	echo "DB_USER not set in ${config_file}"
	err_exit=1
fi
if [ "${REMOTE_CONN}" = "" ]; then
	echo "REMOTE_CONN not set in ${config_file} (ex: name@hosting.provider.com)"
	err_exit=1
fi
if [ "${REMOTE_DIR}" = "" ]; then
	echo "REMOTE_DIR not set in ${config_file}, default=\"~\""
	REMOTE_DIR="~"
fi
if [ "$err_exit" != "0" ]; then
	exit 1
fi

START_TIME=$(date +"%Y-%m-%dT%H:%M")

TRIM_LOCAL=$(echo ${LOCAL_DIR} | sed -e "s@\(.*\)/\$@\1@")
TRIM_REMOTE=$(echo ${REMOTE_DIR} | sed -e "s@\(.*\)/\$@\1@")

EXC_ARGS="--exclude=.git/"
for e in ${EXCLUDE}; do
	EXC_ARGS="--exclude=$e $EXC_ARGS"
done

set -x
if [ ! -d "${TRIM_LOCAL}/.git" ]; then
	cd ${TRIM_LOCAL}
	git init
	git add .
	git commit -m "initial commit"
fi

rsync --delete -crvz ${EXC_ARGS} "${REMOTE_CONN}:${TRIM_REMOTE}/" "${TRIM_LOCAL}/"

ssh -C ${REMOTE_CONN} "mysqldump -h ${DB_HOST}  -u ${DB_USER} --databases ${DB_NAME} -p${DB_PW} --skip-extended-insert" > ${TRIM_LOCAL}/sqldump.sql

git -C ${TRIM_LOCAL} add -A .
git -C ${TRIM_LOCAL} commit -m "automated backup live site ${START_TIME} to $(date +"%Y-%m-%dT%H:%M") from ${REMOTE_CONN}:${TRIM_REMOTE} with db ${DB_NAME}"

