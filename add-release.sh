# install github cli first

TAG=$1

if [ $# -eq 0 ]
  then
    echo "No TAG supplied"
    exit -1
fi

mkdir -p dist
RELEASE_SCRIPT_SRC=./scripts
RELEASE_SCRIPT_FILE=./dist/scripts-$TAG.tar.gz
rm -rf $RELEASE_SCRIPT_FILE && tar -C $RELEASE_SCRIPT_SRC -czvf $RELEASE_SCRIPT_FILE ./
gh release create $TAG $RELEASE_SCRIPT_FILE -t $TAG