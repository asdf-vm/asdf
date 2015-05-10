source $(dirname $(dirname $0))/lib/utils.sh

source_path=$(get_source_path $1)
check_if_source_exists $source_path
versions=$( ${source_path}/bin/list-all )

IFS=' ' read -a versions_list <<< "$versions"

for version in "${versions_list[@]}"
do
  echo "${version}"
done
