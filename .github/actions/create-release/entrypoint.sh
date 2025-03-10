#!/bin/sh

set -e

# extract info
version=`cat $VERSION_FILE`
old_build=`cat $BUILD_FILE`
build=`python /semver.py $old_build`
release_version="${version}-${build}"
blob_dir=$(pwd)

remote_repo="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

# configure git
git config --global user.name "actions/bosh-releaser@v1"
git config --global user.email "<>"
git config --global --add safe.directory /github/workspace

echo "installing bundler"
apk add ruby
gem install bundler

rm -rf .final_builds
rm -rf releases
echo '{}' > config/blobs.yml
echo '{}' > ${blob_dir}/config/blobs.yml
cat - > config/final.yml <<EOS
---
name: curator-boshrelease
blobstore:
  provider: local
  options:
    blobstore_path: ${blob_dir}/blobs
EOS

name=$(yq -r .final_name config/final.yml)
if [ "${name}" = "null" ]; then
  name=$(yq -r .name config/final.yml)
fi

echo "name: $name"

mkdir -p .downloads
cd .downloads
echo "Downloading Python"
curl -L -J -o Python-3.8.0.tgz https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tgz
bosh add-blob --dir=${blob_dir} Python-3.8.0.tgz python3/Python-3.8.0.tgz 

echo "Downloading libffi6"
curl -L -J -o libffi6_3.2.1-8_amd64.deb http://archive.ubuntu.com/ubuntu/pool/main/libf/libffi/libffi6_3.2.1-8_amd64.deb
bosh add-blob --dir=${blob_dir} libffi6_3.2.1-8_amd64.deb python3/libffi6_3.2.1-8_amd64.deb
echo "Downloading libffi-dev"
curl -L -J -o libffi-dev_3.2.1-8_amd64.deb http://archive.ubuntu.com/ubuntu/pool/main/libf/libffi/libffi-dev_3.2.1-8_amd64.deb
bosh add-blob --dir=${blob_dir} libffi-dev_3.2.1-8_amd64.deb python3/libffi-dev_3.2.1-8_amd64.deb

echo "Downloading Curator"
pip download -d curator --no-binary :all: elasticsearch-curator==${version}
echo "Downloading Setuptools"
pip download -d curator --no-binary :all: setuptools==45.0.0
echo "Downloading Setuptools_scm"
pip download -d curator --no-binary :all: setuptools_scm==7.0.4

echo "Adding Blobs"
for f in $(ls curator/*.tar.gz);do 
  bosh add-blob --dir=${blob_dir} ${f} ${f}
done

cd ../
echo "creating bosh release: ${name}-${release_version}.tgz"
bosh create-release --force --final --version=${release_version} --tarball=${name}-${release_version}.tgz

echo $build > build-version

echo "pushing changes to git repository"
git add releases/${name}/${name}-${release_version}.yml build-version config/
git commit -a -m "cutting release ${release_version}"
git push ${remote_repo} HEAD:${INPUT_TARGET_BRANCH}

# make asset readble outside docker image
chmod 644 ${name}-${release_version}.tgz
echo "::set-output name=file::${name}-${release_version}.tgz"
echo "::set-output name=version::${release_version}"

