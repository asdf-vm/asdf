# -*- sh -*-

search_command() {
  local target="$1"
  curl -s https://api.github.com/repos/asdf-vm/asdf-plugins/contents/plugins | jq -r ".[]|.name" | grep -i $target
 }
 
 search_command $@
