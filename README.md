```
./add-blobs.sh
bosh create-release --name=curator --force --timestamp-version --tarball=/tmp/curator-boshrelease.tgz && bosh upload-release /tmp/curator-boshrelease.tgz

```
