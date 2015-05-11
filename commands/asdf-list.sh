source $(dirname $(dirname $0))/lib/utils.sh

package=$1
source_path=$(get_source_path $package)
check_if_source_exists $source_path

package_installs_path=$(asdf_dir)/installs/${package}

if [ -d $package_installs_path ]
then
  #TODO check if dir is empty and show no-installed-versions msg
  for install in ${package_installs_path}/*/; do
    echo "$(basename $install)"
  done
else
  echo 'Oohes nooes ~! Nothing found'
fi
