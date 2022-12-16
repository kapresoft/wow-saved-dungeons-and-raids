#!/usr/bin/env zsh

IncludeBase() {
  local fnn="script-functions.sh"
  local fn="dev/${fnn}"
  if [ -f "${fn}" ]; then
    source "${fn}"
  elif [ -f "${fnn}" ]; then
    source "${fnn}"
  else
    echo "${fn} not found" && exit 1
  fi
}
IncludeBase && Validate && InitDirs

# --------------------------------------------
# Vars / Support Functions
# --------------------------------------------

Package() {
  local arg1=$1
  local rel_dir=$RELEASE_DIR
  # -c Skip copying files into the package directory.
  # -d Skip uploading.
  # -e Skip checkout of external repositories.
  # default: -cdzul
  # for checking debug tags: -edzul
  local rel_cmd="${release_script} -r ${RELEASE_DIR} -cdzul $*"

  if [[ "$arg1" == "-h" ]]; then
    echo "Usage: $0 [-o]"
    echo "Options:  "
    echo "  -o to keep existing release directory"
    exit 0
  fi

  if [[ -d ${RELEASE_DIR} ]]; then
    echo "$rel_dir dir exists"
    rel_cmd="${rel_cmd}"
  fi
  echo "Executing: $rel_cmd"
  eval "$rel_cmd"
}

SyncExtLib() {
  local src="${RELEASE_DIR}/${ADDON_NAME}/${WOW_ACE_LIB_DIR}/"
  local dest="${WOW_ACE_LIB_DIR}/."
  SyncDir "${src}" "${dest}"
}

SyncKapresoftLib() {
  local src="${RELEASE_DIR}/${ADDON_NAME}/${EXT_UTIL_LIB_DIR}/"
  local dest="${EXT_UTIL_LIB_DIR}/."
  SyncDir "${src}" "${dest}"
}

#SyncExtLib && SyncKapresoftLib
Package $* && SyncExtLib && SyncKapresoftLib