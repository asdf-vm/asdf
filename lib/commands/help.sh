set -o nounset -o pipefail -o errexit
IFS=$'\t\n' # Stricter IFS settings

help_command () {
  echo "version: $(asdf_version)"
  echo ""
  cat "$(asdf_dir)/help.txt"
}
