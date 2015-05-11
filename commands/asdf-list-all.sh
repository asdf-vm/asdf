source $(dirname $(dirname $0))/lib/utils.sh

package_name=$1
source_path=$(get_source_path $package_name)
check_if_source_exists $source_path
versions=$( ${source_path}/bin/list-all )

IFS=' ' read -a versions_list <<< "$versions"

for version in "${versions_list[@]}"
do
  echo "${version}"
done
