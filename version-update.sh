#!/bin/bash

if which node > /dev/null then
  echo "Node must be installed. https://nodejs.org/en/"
  exit 1;
fi

function find_base_dir {
    local real_path=$(python -c "import os,sys;print os.path.realpath('$0')")
    local dir_name="$(dirname "$real_path")"
    BASEDIR="${dir_name}/.."
}

function updateJsonVersion {
  version=$1
  json_file=$2

  if [ ! -f $json_file ]; then
    echo "$json_file was not found."
  else
    temp=$json_file.tmp

    node > $temp <<EOF
      var data = require('./${json_file}');
      delete data.version
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

find_base_dir

bower="$BASEDIR/bower.json"
package="$BASEDIR/package.json"
composer="$BASEDIR/composer.json"

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
      for file in $bower $package $composer; do
        updateJsonVersion $version $file
      done
      exit 0;
      ;;
esac
done