#/usr/bin/env sh

asdf_dir=$(cd $(dirname $0); echo $(pwd))
export PATH="$(asdf_dir)/bin:$(asdf_dir)/shims:$PATH"
