#!/bin/bash
export MUDHOME=${MUDHOME:-"/opt/deadsouls"}
MUD_LIB_DIR=${MUD_LIB_DIR:-"$MUDHOME/lib"}
MUD_BIN_DIR=${MUD_BIN_DIR:-"$MUDHOME/bin"}
# this is a relative path inside MUD_LIB_DIR
MUD_LOG_DIR=${MUD_LOG_DIR:-"/log"}
MUD_LOG_DIR_ON_DISK="${MUD_LIB_DIR}${MUD_LOG_DIR}"
mkdir -p $MUD_LOG_DIR_ON_DISK
MUD_SECURE_DIR=${MUD_SECURE_DIR:-"/secure"}

DS_CONFIG_FILE=${DS_CONFIG_FILE:-"$MUDHOME/config/mudos.cfg"}

DEFAULT_CONFIG_FILE=${DEFAULT_CONFIG_FILE:-"$MUDHOME/mudos.tpl"}
DS_SERVER_NAME=${DS_SERVER_NAME:-"NewDeadSoulsDocker"}
DS_SERVER_PORT=${DS_SERVER_PORT:-"6666"}
DS_ADDR_SERVER=${DS_ADDR_SERVER:-"localhost"}
DS_ADDR_PORT=${DS_ADDR_PORT:-"8099"}


DEFAULT_FAIL_MESSAGE=${DEFAULT_FAIL_MESSAGE:-"What?"}
DEFAULT_ERROR_MESSAGE=${DEFAULT_ERROR_MESSAGE:-"Something *REALLY* bad just happened."}

SERVER_CMD=${SERVER_CMD:-"$MUD_BIN_DIR/driver"}

if [ ! -f "$DS_CONFIG_FILE" ]; then
    echo "Missing config file @ ${DS_CONFIG_FILE}"
    tmp=$(mktemp -d)/values.yml
    echo "---" > $tmp
    echo "serverName: ${DS_SERVER_NAME}" >> $tmp
    echo "serverPort: ${DS_SERVER_PORT}" >> $tmp
    echo "addrServerName: ${DS_ADDR_SERVER}" >> $tmp
    echo "addrServerPort: ${DS_ADDR_PORT}" >> $tmp
    echo "mudLibDir: ${MUD_LIB_DIR}" >> $tmp
    echo "mudBinDir: ${MUD_BIN_DIR}" >> $tmp
    echo "mudLogDir: ${MUD_LOG_DIR}" >> $tmp
    echo "secureDir: ${MUD_SECURE_DIR}" >> $tmp
    echo "defaultFailMessage: '${DEFAULT_FAIL_MESSAGE}'" >> $tmp
    echo "defaultErrorMessage: '${DEFAULT_ERROR_MESSAGE}'" >> $tmp
    
    echo -e "\033[33mConfig Template Values:"
    cat $tmp;
    echo -e "\033[0m"
    
    gotpl $DEFAULT_CONFIG_FILE < $tmp > $DS_CONFIG_FILE
fi

if [ ! -f "$DS_CONFIG_FILE" ]; then
    >&2 echo "error: DS_CONFIG_FILE ${DS_CONFIG_FILE} does not exist"
    exit 1
fi

ulimit -a
ulimit -n ${ULIMIT_MAX_FILES:-2048}
ulimit -a


echo "Writing logs to ${MUD_LOG_DIR_ON_DISK}"
$MUDHOME/bin/driver $DS_CONFIG_FILE
