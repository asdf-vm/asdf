source $(dirname $(dirname $0))/lib/utils.sh

source_path=$(get_source_path $1)
check_if_source_exists $source_path
list_package_installs $1
