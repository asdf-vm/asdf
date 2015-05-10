source $(dirname $(dirname $0))/lib/utils.sh

package=$1
version=$2

source_path=$(get_source_path $package)
check_if_source_exists $source_path


if [ ! -d $(asdf_dir)/shims ]
  then
  mkdir $(asdf_dir)/shims
fi


package_installs_path=$(asdf_dir)/installs/${package}

if [ $version = "" ]
then
  #TODO add support to parse "tag-$version" dir names to what we want
  for install in ${package_installs_path}/*/; do
    echo "TODO"
    echo "$(basename $install)"
  done
else
  generate_shims_for_version $package $version "${@:3}"
fi
