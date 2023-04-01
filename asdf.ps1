$Env:ASDF_DIR = $PSScriptRoot

$_asdf_bin = "$Env:ASDF_DIR/bin"
if ($null -eq $ASDF_DATA_DIR -or $ASDF_DATA_DIR -eq '') {
  $_asdf_shims = "${env:HOME}/.asdf/shims"
}
else {
  $_asdf_shims = "$ASDF_DATA_DIR/shims"
}

$env:PATH = "${_asdf_bin}:${_asdf_shims}:${env:PATH}"

if ($env:PATH -cnotlike "*${_asdf_bin}*") {
  $env:PATH = "_asdf_bin:${env:PATH}"
}
if ($env:PATH -cnotlike "*${_asdf_shims}*") {
  $env:PATH = "_asdf_shims:${env:PATH}"
}

Remove-Variable -Force _asdf_bin, _asdf_shims

function asdf {
  $asdf = $(Get-Command -CommandType Application asdf).Source

  if ($args.Count -gt 0 -and $args[0] -eq 'shell') {
    Invoke-Expression $(& $asdf 'export-shell-version' pwsh $args[1..($args.Count + -1)])
  }
  else {
    & $asdf $args
  }
}
