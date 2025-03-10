#!/bin/bash

DIR=`pwd`

mkdir -p .downloads

cd .downloads

blob_download() {
  set -eu
  local package=$1
  local url=$2
  local f=$3
  if [ ! -f ${DIR}/blobs/${package}/${f} ];then
    curl -L -J ${url} -o ${f}
    bosh add-blob --dir=${DIR} ${f} ${package}/${f}
  fi
}

blob_download python3 https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tgz Python-3.8.0.tgz

pip download -d curator --no-binary :all: elasticsearch-curator==5.8.4
pip download -d curator --no-binary :all: setuptools_scm==3.2.0

for f in $(ls curator/*.tar.gz);do 
  bosh add-blob --dir=${DIR} ${f} ${f}
done
