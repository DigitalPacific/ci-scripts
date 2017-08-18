#!/bin/bash

node=`which node > /dev/null`
node_exists=$?

if [ $node_exists -ne 0 ]; then
  echo "Node must be installed. https://nodejs.org/en/";
  exit 1;
fi

function updateJsonVersion {
  version=$1
  json_file=$2

  if [ ! -f $json_file ]; then
    echo "$json_file was not found."
  else
    temp=$json_file.tmp

    node > $temp <<EOF
      var data = require('./${json_file}');
      data.version = '${version}';
      console.log(JSON.stringify(data, null, 4));
EOF
    mv $temp $json_file
    echo "$json_file updated."
  fi
}

function usage {
  cat <<EOF

Updates the version of composer, bower & package files
Usage: $0 [options] version

Options:
    --bower, -b          Specify absolute path to the bower.json
    --package, -p        Specify absolute path to the package.json
    --composer, -c       Specify absolute path to the composer.json
    --help, -h           Show this usage information

EOF
}

bower="bower.json"
package="package.json"
composer="composer.json"
while [ "$#" -gt 0 ]; do
  case "$1" in
    (--bower|-b)
      bower="${2}"
      shift 2
      ;;
    (--package|-p)
      package="${2}"
      shift 2
      ;;
    (--composer|-c)
      composer="${2}"
      shift 2
      ;;
    (--help|-h)
      usage
      shift
      exit 0
      ;;
    (--)
      shift
      break
      ;;
    (*)
      version=$1
      shift
      ;;
esac
done

for file in $bower $package $composer; do
  updateJsonVersion $version $file
done
