# Changelog

## [0.11.3](https://github.com/asdf-vm/asdf/compare/v0.11.2...v0.11.3) (2023-03-16)


### Bug Fixes

* Prepend asdf directories to the PATH in Nushell ([#1496](https://github.com/asdf-vm/asdf/issues/1496)) ([745950c](https://github.com/asdf-vm/asdf/commit/745950c3589c4047a5b94b34bc9cf06dff5dc3c7))

## [0.11.2](https://github.com/asdf-vm/asdf/compare/v0.11.1...v0.11.2) (2023-02-21)


### Bug Fixes

* bash completion for latest command ([#1472](https://github.com/asdf-vm/asdf/issues/1472)) ([2606a87](https://github.com/asdf-vm/asdf/commit/2606a875eba8d74be56c78c97a76f3eb92c8253d))
* enforce & use consistent function definitions ([#1464](https://github.com/asdf-vm/asdf/issues/1464)) ([e0fd7a7](https://github.com/asdf-vm/asdf/commit/e0fd7a7be8bbbbf0f3cb6dc38cea3b62963eb0c9))
* nushell PATH conversion to list before filter ([#1471](https://github.com/asdf-vm/asdf/issues/1471)) ([cd0e12b](https://github.com/asdf-vm/asdf/commit/cd0e12b3ee4090242b884ac4aea0f65784e52946))
* Remove `==` inside `[` ([#1421](https://github.com/asdf-vm/asdf/issues/1421)) ([d81b81f](https://github.com/asdf-vm/asdf/commit/d81b81f9de2dc5961624464df04cef7cafae588c))
* support nushell v0.75.0 ([#1481](https://github.com/asdf-vm/asdf/issues/1481)) ([dd8d399](https://github.com/asdf-vm/asdf/commit/dd8d3999d41cfdd8518a9ea478929b5291b8838c))

## [0.11.1](https://github.com/asdf-vm/asdf/compare/v0.11.0...v0.11.1) (2023-01-13)


### Bug Fixes

* `reshim` did not rewrite executable path ([#1311](https://github.com/asdf-vm/asdf/issues/1311)) ([5af7625](https://github.com/asdf-vm/asdf/commit/5af76257693d1f560b9c27c9cdcc6f5a5a33c4d5))
* Add test for nushell integration and fix some bugs ([#1415](https://github.com/asdf-vm/asdf/issues/1415)) ([60d4494](https://github.com/asdf-vm/asdf/commit/60d4494d5d21f9d7bdd0778ca962ddb44280aff7))
* Allow `path:` versions to use `~` ([#1403](https://github.com/asdf-vm/asdf/issues/1403)) ([670c96d](https://github.com/asdf-vm/asdf/commit/670c96d1a6d6d2c19ff63ce2ed14f784c340e9b9))
* Ban use of 'test' ([#1383](https://github.com/asdf-vm/asdf/issues/1383)) ([ec972cb](https://github.com/asdf-vm/asdf/commit/ec972cbdf0acbecf70e3678c055e27866c49341d))
* correct order of checks in conditional for adding a missing newline ([#1418](https://github.com/asdf-vm/asdf/issues/1418)) ([4125d2b](https://github.com/asdf-vm/asdf/commit/4125d2b5560efc646e6048202ceb00fffd0b9eaf)), closes [#1417](https://github.com/asdf-vm/asdf/issues/1417)
* Do not use `pwd` ([dd37b6f](https://github.com/asdf-vm/asdf/commit/dd37b6f0c0ed20d15e3d96b730db82f21c9e2e6f))
* Do not use type not exported on older Python versions ([#1409](https://github.com/asdf-vm/asdf/issues/1409)) ([7460809](https://github.com/asdf-vm/asdf/commit/74608098cdfc70c2d2e85d1f3861500ef668a041))
* force lwrcase plugin name fix capitalization mismatch errs ([#1400](https://github.com/asdf-vm/asdf/issues/1400)) ([196a05b](https://github.com/asdf-vm/asdf/commit/196a05b2dcef48f3a281350734c76ba7bc73fa81))
* lint errors from `scripts/checkstyle.py` ([#1385](https://github.com/asdf-vm/asdf/issues/1385)) ([3492043](https://github.com/asdf-vm/asdf/commit/3492043241e466337c5965a6fe2e089147bc4152))
* mv dev dep from repo root to subdir to avoid clash ([#1408](https://github.com/asdf-vm/asdf/issues/1408)) ([5df70da](https://github.com/asdf-vm/asdf/commit/5df70dadacd66b4150ed47e58c861418c0d1281f))
* Remove unecessary backslashes ([#1384](https://github.com/asdf-vm/asdf/issues/1384)) ([15faf93](https://github.com/asdf-vm/asdf/commit/15faf93a0d3615834e550ea1562fb6b8cee5a205))
* Remove usage of `$(pwd)` in favor of `$PWD` ([f522ab9](https://github.com/asdf-vm/asdf/commit/f522ab98797345d767b239041246dfb4b740423e))

## [0.11.0](https://github.com/asdf-vm/asdf/compare/v0.10.2...v0.11.0) (2022-12-12)


### Features

* **completions:** bash improvements ([#1329](https://github.com/asdf-vm/asdf/issues/1329)) ([7c802c3](https://github.com/asdf-vm/asdf/commit/7c802c3fc9b5dc556993a98e5aaf96650cbb0d5b))
* Disable short-name repository with config value ([#1227](https://github.com/asdf-vm/asdf/issues/1227)) ([18caea3](https://github.com/asdf-vm/asdf/commit/18caea3eb7d989d195cf13b3c9ffc2058d906fc5))
* mark current resolved versions in `asdf list` output ([#762](https://github.com/asdf-vm/asdf/issues/762)) ([5ea6795](https://github.com/asdf-vm/asdf/commit/5ea67953be74cb5fde11240dc40a541c69afc65c))
* support nushell ([#1355](https://github.com/asdf-vm/asdf/issues/1355)) ([274a638](https://github.com/asdf-vm/asdf/commit/274a638e155c08cd0d6dbda1a0d4da02c3466c97))


### Bug Fixes

* add missing "does not add paths to PATH more than once" test for elvish ([#1275](https://github.com/asdf-vm/asdf/issues/1275)) ([3c55167](https://github.com/asdf-vm/asdf/commit/3c55167a6807b48cacaaed18df7bf0db2526ed59))
* append trailing newline to .tool-versions files when missing ([#1310](https://github.com/asdf-vm/asdf/issues/1310)) ([eb7dac3](https://github.com/asdf-vm/asdf/commit/eb7dac3a2b15ad458f55a897d49a377508ea92fe)), closes [#1299](https://github.com/asdf-vm/asdf/issues/1299)
* excludes "milestone" releases in "latest" command ([#1307](https://github.com/asdf-vm/asdf/issues/1307)) ([5334d1d](https://github.com/asdf-vm/asdf/commit/5334d1db3d390c46ed49101528f74483eb6b2987)), closes [#1306](https://github.com/asdf-vm/asdf/issues/1306)
* improve formatting of ballad ([#1367](https://github.com/asdf-vm/asdf/issues/1367)) ([e0c2c31](https://github.com/asdf-vm/asdf/commit/e0c2c31fc3274387efdddebe1450f0662f91a726))
* use ELVISH_VERSION to specify elvish test version ([#1276](https://github.com/asdf-vm/asdf/issues/1276)) ([72c3a23](https://github.com/asdf-vm/asdf/commit/72c3a2377a1afa3027c6f29cb9f3f1a7fbddaa8c))

### [0.10.2](https://www.github.com/asdf-vm/asdf/compare/v0.10.1...v0.10.2) (2022-06-08)


### Bug Fixes

* always use ASDF_DEFAULT_TOOL_VERSIONS_FILENAME for filename when present ([#1238](https://www.github.com/asdf-vm/asdf/issues/1238)) ([711ad99](https://www.github.com/asdf-vm/asdf/commit/711ad991043a1980fa264098f29e78f2ecafd610)), closes [#1082](https://www.github.com/asdf-vm/asdf/issues/1082)
* get invalid ASDF_DATA_DIR when exec asdf shims by non-shell ([#1154](https://www.github.com/asdf-vm/asdf/issues/1154)) ([b9962f7](https://www.github.com/asdf-vm/asdf/commit/b9962f71564ce77cf97772cc100b80f9d77019b1))
* update event trigger for doc-version workflow ([#1232](https://www.github.com/asdf-vm/asdf/issues/1232)) ([0bc8c3a](https://www.github.com/asdf-vm/asdf/commit/0bc8c3ab6895b88c96bff86f5f79575ee80cc718))
* update plugin-add regex to support other languages ([#1241](https://www.github.com/asdf-vm/asdf/issues/1241)) ([92d005d](https://www.github.com/asdf-vm/asdf/commit/92d005dacd2ec434a9d912ab9938b59ab1b7c51f)), closes [#1237](https://www.github.com/asdf-vm/asdf/issues/1237)
* updating references to legacy github.io site ([#1240](https://www.github.com/asdf-vm/asdf/issues/1240)) ([738306b](https://www.github.com/asdf-vm/asdf/commit/738306bc5d1c53a22c06e4d6d3ddb6d511dc5d50))

### [0.10.1](https://www.github.com/asdf-vm/asdf/compare/v0.10.0...v0.10.1) (2022-05-17)


### Bug Fixes

* add asdf to list of banned commands ([#1224](https://www.github.com/asdf-vm/asdf/issues/1224)) ([39909e0](https://www.github.com/asdf-vm/asdf/commit/39909e01af2bbf23fc821de5cec6c5c9661c59bb))
* don't invoke asdf inside asdf commands ([#1208](https://www.github.com/asdf-vm/asdf/issues/1208)) ([27f7ef7](https://www.github.com/asdf-vm/asdf/commit/27f7ef78529649534b8383daa58e4b370b3cbd7f))
* fixing bats ([#1215](https://www.github.com/asdf-vm/asdf/issues/1215)) ([a9caa5b](https://www.github.com/asdf-vm/asdf/commit/a9caa5bdffca5401798fb37e6f34af933b6ce0d2))
* instead /tmp, use TMPDIR if defined ([9113623](https://www.github.com/asdf-vm/asdf/commit/91136234e90b5fe8718338f513fa770c99151d3e))
* make fish shell setup match other shells ([#1209](https://www.github.com/asdf-vm/asdf/issues/1209)) ([6fc4bb8](https://www.github.com/asdf-vm/asdf/commit/6fc4bb8fc650e73152ce326267f89df6865cdd24))
* only iterate over directories in the plugins/ directory ([#1228](https://www.github.com/asdf-vm/asdf/issues/1228)) ([788ccab](https://www.github.com/asdf-vm/asdf/commit/788ccab5971cb828cf25364b0df5ed6f5e9e713d))
* update elvish to 0.18.0 ([5a89563](https://www.github.com/asdf-vm/asdf/commit/5a89563c0a37f244fa3daa46c5100b7711edde1d))

## [0.10.0](https://www.github.com/asdf-vm/asdf/compare/v0.9.0...v0.10.0) (2022-04-14)


### Features

* case-insensitive filtering of unstable versions in `latest` ([#1139](https://www.github.com/asdf-vm/asdf/issues/1139)) ([e61e3d9](https://www.github.com/asdf-vm/asdf/commit/e61e3d9ade0d7bdfb4413184284038c50ba1e09c))
* **latest:** adds the flag --all to the latest command ([#1096](https://www.github.com/asdf-vm/asdf/issues/1096)) ([f85fef5](https://www.github.com/asdf-vm/asdf/commit/f85fef533f249df5a9f58307d288f2f069351e88))
* upgrade elvish to 0.17.0 ([#1159](https://www.github.com/asdf-vm/asdf/issues/1159)) ([824550e](https://www.github.com/asdf-vm/asdf/commit/824550ed2009c7e8c4c84afd7a01197d451c47bf))


### Bug Fixes

* Ban `ls` command ([#1141](https://www.github.com/asdf-vm/asdf/issues/1141)) ([87137e4](https://www.github.com/asdf-vm/asdf/commit/87137e41031f17b30acf12ee35925e689c84e2d8))
* ban grep long flags ([#1117](https://www.github.com/asdf-vm/asdf/issues/1117)) ([6e4c39c](https://www.github.com/asdf-vm/asdf/commit/6e4c39c244a289a54f235cf15a29874fb8885927))
* do not print `find` errors ([#1102](https://www.github.com/asdf-vm/asdf/issues/1102)) ([5992abb](https://www.github.com/asdf-vm/asdf/commit/5992abb09e6f5e0af690bf0e99619386187949db))
* don't generate on error if backup file doesn't exists ([#1057](https://www.github.com/asdf-vm/asdf/issues/1057)) ([288468f](https://www.github.com/asdf-vm/asdf/commit/288468f93f6c5cb4e7cca1173d4ad73154d0d564))
* **elvish:** prepend asdf paths to `$PATH` ([#1174](https://www.github.com/asdf-vm/asdf/issues/1174)) ([682b7a1](https://www.github.com/asdf-vm/asdf/commit/682b7a1d6dc1a35f7f8b0ddbab977e0a3dae2c9c))
* latest --all correctly report plugins as missing ([#1118](https://www.github.com/asdf-vm/asdf/issues/1118)) ([aafe1e5](https://www.github.com/asdf-vm/asdf/commit/aafe1e5304c2d2a026831976c18faa6fb48d25bc))
* local plugin in then clause too ([#1203](https://www.github.com/asdf-vm/asdf/issues/1203)) ([448f750](https://www.github.com/asdf-vm/asdf/commit/448f750891a4366f45d905b112ad20d4be66c496))
* newline after error msg for ASDF_DIR ([#1113](https://www.github.com/asdf-vm/asdf/issues/1113)) ([ac2791e](https://www.github.com/asdf-vm/asdf/commit/ac2791e49f7fcdbeb420415d8ddcb5f17bcf296e))
* Prevent unbound variable error with nounset in asdf.sh ([#1158](https://www.github.com/asdf-vm/asdf/issues/1158)) ([b7dd291](https://www.github.com/asdf-vm/asdf/commit/b7dd291c983af321af20550fa89bf1cfbc888aec))
* remove comments from whole file instead of line by line for performance ([#1198](https://www.github.com/asdf-vm/asdf/issues/1198)) ([de6e22f](https://www.github.com/asdf-vm/asdf/commit/de6e22f909946f7d17047f4aeab41e581546b674))
* shorthand grep options for alpine support ([#1106](https://www.github.com/asdf-vm/asdf/issues/1106)) ([234778a](https://www.github.com/asdf-vm/asdf/commit/234778a397f19c398d2f76a0321fef3273c9a086))

## [0.9.0](https://www.github.com/asdf-vm/asdf/compare/v0.8.1...v0.9.0) (2021-11-18)


### Features

* add post update plugin support ([#1049](https://www.github.com/asdf-vm/asdf/issues/1049)) ([304f72d](https://www.github.com/asdf-vm/asdf/commit/304f72dbb207606fd82c04ee2c73cf11e9e6e0cc))
* asdf latest defer to plugin to determine the latest version ([#938](https://www.github.com/asdf-vm/asdf/issues/938)) ([664d82e](https://www.github.com/asdf-vm/asdf/commit/664d82ed8a734eb30988840829a972f8ddd8e523))
* configurable plugin repo last check time ([#957](https://www.github.com/asdf-vm/asdf/issues/957)) ([1716afa](https://www.github.com/asdf-vm/asdf/commit/1716afa02125aa322d8a688ff4b3e95f2e08b33c))
* display plugin repo refs alongside urls in info cmd ([#1014](https://www.github.com/asdf-vm/asdf/issues/1014)) ([cd0a6a7](https://www.github.com/asdf-vm/asdf/commit/cd0a6a779eb18236fe7bf1f84403e33e636ef1f3))
* Displays a warning when a plugin from the tools-version list does not exist ([#1033](https://www.github.com/asdf-vm/asdf/issues/1033)) ([9430a39](https://www.github.com/asdf-vm/asdf/commit/9430a39aef1dbf806a8954d71711747be1001076))
* Elvish Shell support ([#1066](https://www.github.com/asdf-vm/asdf/issues/1066)) ([cc7778a](https://www.github.com/asdf-vm/asdf/commit/cc7778a040751f6801524135f5f5ece3a748fa8c))
* toggle off repo sync completely ([#1011](https://www.github.com/asdf-vm/asdf/issues/1011)) ([a3ba5a7](https://www.github.com/asdf-vm/asdf/commit/a3ba5a794c07efb4aa9cce9c15d41b4b61d5df01))


### Bug Fixes

* Adds "grep -P" to the list of banned commands ([#1064](https://www.github.com/asdf-vm/asdf/issues/1064)) ([8a515f4](https://www.github.com/asdf-vm/asdf/commit/8a515f49d7443ee318badbd4d8f092ad0d8f04ca))
* allow plugin callbacks to be in any language ([#995](https://www.github.com/asdf-vm/asdf/issues/995)) ([2ad0f5e](https://www.github.com/asdf-vm/asdf/commit/2ad0f5ea452bd8f843951c4a9cc56a020e172b07))
* clarify the wording when no version is set ([#1088](https://www.github.com/asdf-vm/asdf/issues/1088)) ([4116284](https://www.github.com/asdf-vm/asdf/commit/41162849cf5c966c749ec435ebe32bd649a86ee8))
* completions for asdf plugin list ([#1061](https://www.github.com/asdf-vm/asdf/issues/1061)) ([43412aa](https://www.github.com/asdf-vm/asdf/commit/43412aad5f668686daa058505a61c070561b46fc))
* Correct typo on getting started page ([#1086](https://www.github.com/asdf-vm/asdf/issues/1086)) ([4321980](https://www.github.com/asdf-vm/asdf/commit/4321980c3385ac1bafd77503c8ec77b26042d05b))
* don't override existing ASDF_DIR ([#1008](https://www.github.com/asdf-vm/asdf/issues/1008)) ([73efc9f](https://www.github.com/asdf-vm/asdf/commit/73efc9fa97744c49c5004ee8bb9b6064b6ce22f2))
* ensure shims get created when data dir has spaces ([#996](https://www.github.com/asdf-vm/asdf/issues/996)) ([39c9999](https://www.github.com/asdf-vm/asdf/commit/39c9999519a1d3c51ffb3b8dddd141dbc29b3bd1))
* Fix plugin-test arg parsing ([#1084](https://www.github.com/asdf-vm/asdf/issues/1084)) ([c911f2d](https://www.github.com/asdf-vm/asdf/commit/c911f2d43198945f21bb25100c9dab5a375c780b))
* full_version_name is not available here ([#1031](https://www.github.com/asdf-vm/asdf/issues/1031)) ([8490526](https://www.github.com/asdf-vm/asdf/commit/84905265467c9fdf618c11f69a5ae71408e18bea))
* help for extension commands for plugins with hyphens in the name. ([#1048](https://www.github.com/asdf-vm/asdf/issues/1048)) ([3e0cb9a](https://www.github.com/asdf-vm/asdf/commit/3e0cb9aaea7f2bf282a18c4912454737fef0741b))
* help text as per new feats in [#633](https://www.github.com/asdf-vm/asdf/issues/633) ([#991](https://www.github.com/asdf-vm/asdf/issues/991)) ([0d95663](https://www.github.com/asdf-vm/asdf/commit/0d956635b5cabe35f0895121929e8e668a3ee03d))
* incorrect usage of grep ([#1035](https://www.github.com/asdf-vm/asdf/issues/1035)) ([30d27cb](https://www.github.com/asdf-vm/asdf/commit/30d27cbe6b358cd790fb66dbc8a14806eca23f05))
* insert error handling in list-all & download plugin scripts ([#881](https://www.github.com/asdf-vm/asdf/issues/881)) ([a7d3661](https://www.github.com/asdf-vm/asdf/commit/a7d3661f6c53b24ae1c21e93f94209f3af243349))
* lint scripts for local and CI ([#961](https://www.github.com/asdf-vm/asdf/issues/961)) ([5dafbc8](https://www.github.com/asdf-vm/asdf/commit/5dafbc8e390eacbcfcf97d6d2890e0aa6ef9cd60))
* pipe find into while ([26d2c64](https://www.github.com/asdf-vm/asdf/commit/26d2c64477a1faabedd9a5f97aa7da706988cd72))
* Quote commands correctly in plugin-test ([#1078](https://www.github.com/asdf-vm/asdf/issues/1078)) ([69ff2d0](https://www.github.com/asdf-vm/asdf/commit/69ff2d0c9a4fd273c9dac151345f60f7b146e569))
* regex validate plugin names on plugin add cmd ([#1010](https://www.github.com/asdf-vm/asdf/issues/1010)) ([7697e6e](https://www.github.com/asdf-vm/asdf/commit/7697e6e344809ab4603d0764fb8a969c2bbaf3b6))
* remove find -print0 ([b9228a2](https://www.github.com/asdf-vm/asdf/commit/b9228a26de6a0337a7b59fb5252323d368a72a92))
* Sed improvements ([#1087](https://www.github.com/asdf-vm/asdf/issues/1087)) ([4b93bc8](https://www.github.com/asdf-vm/asdf/commit/4b93bc81aa982b72621cd09e71eeea71ee009185))
* sed re error trailing backslash on FreeBSD ([#1046](https://www.github.com/asdf-vm/asdf/issues/1046)). ([#1047](https://www.github.com/asdf-vm/asdf/issues/1047)) ([47e8fb0](https://www.github.com/asdf-vm/asdf/commit/47e8fb051b3577d251376976d5767c520f3524fc))
* support latest with filter on local and global ([#633](https://www.github.com/asdf-vm/asdf/issues/633)) ([5cf8f89](https://www.github.com/asdf-vm/asdf/commit/5cf8f8962fbd5fe2bc86856bc4676f88e1aa8885))
* Use more idiomatic fish ([#1042](https://www.github.com/asdf-vm/asdf/issues/1042)) ([847ec73](https://www.github.com/asdf-vm/asdf/commit/847ec73751ced9d149ce0826309fee0f894ca664))
* wait until the plugin update are finished ([#1037](https://www.github.com/asdf-vm/asdf/issues/1037)) ([7e1f2a0](https://www.github.com/asdf-vm/asdf/commit/7e1f2a0d938052d4fa5ce6546f07b3decbd740cf))

## 0.8.1

Features

* Support for latest version in shell, local, and global commands (#802, #801)
* Parallel updating of all plugins (#626, #530)
* Print documentation website and GitHub URLs in help command (#820)

Fixed Bugs

* Fix plugin-update --all when there are no plugins (#805, #803)
* Ban `echo` command from asdf codebase (#806, #781)
* Add basic tests for plugin-update command (#807)
* Cleanup unused code in plugin update tests (#810)
* Fix resolution of relative symlinks (#815, #625)
* Fixes to GitHub workflow (#833)
* Update no plugin installed error message (#818)
* Remove process substitution that was problematic when POSIXLY_CORRECT is set (#851, #581)
* Fix warnings from find command (#853)
* Ban the `sort -V` command from the asdf codebase (#755, #867)
* Fix `plugin update --all` so that the default branch is used for each plugin (#800)
* Fix issues with awk command on some platforms used by plugin update command (#924, #899, #919)
* Add completion for the `system` version (#911)

Documentation

* Link to Homebrew common issues from documentation site (#795)
* Remove -vm suffix name in documentation (#798, #796)
* Fix file renames in release script (#809)
* Update supported versions in documentation (#825)
* Fix references to icongram files (#827)
* Fix broken links in CONTRIBUTING.md (#832, #852)
* Fix broken link in README.md (#835)
* Improve zsh completion directions for macOS,ZSH,Homebrew (#843)
* Add GitHub discussions link (#839)
* Add note about unsolicited formatting pull requests (#848)
* Fix formatting of GitHub name (#847)
* Explain the difference between ASDF_DIR and ASDF_DATA_DIR (#855)
* Update BATS link to bats-core GitHub repo (#858)
* Instruct users to symlink completions for Fish shell (#860)
* Support alternate locations for `.zshrc` (#871)
* Add "Add translation" link to navbar (#876)
* Clarify usage of the ASDF_DEFAULT_TOOL_VERSIONS_FILENAME variable (#912, #900)
* Show how to use the `system` version (#925, #868)
* Remove instructions for installing dependencies for Homebrew installs (#937, #936)

## 0.8.0

Features

* Add support for plugin documentation callback scripts (#512, #757)
* Add support for installing one tool specified in `.tool-versions` (#759, #760)
* Improve introduction and install sections of documentation (#699, #740)
* Add dependencies for openSUSE and ArchLinux to documentation (#714)
* Add support for keeping downloaded tool source code (#74, #669)
* Add `asdf info` command to print debug information (#786, #787)

Fixed Bugs

* Fix typo that caused plugin-test to erroneously fail (#780)
* Make sure shims are only appended to `PATH` once in Fish shell (#767, #777, #778)
* Print `.tool-versions` file path on shim error (#749, #750)
* Add `column` and `sort -V` to list of banned commands for the asdf codebase (#661, #754)
* Use editorconfig for shell formatting (#751)
* Remove use of `column` command in favor of awk (#721)
* Add `asdf shell` command to help output (#715, #737)
* Ensure consistency in indentation for message shown when no versions installed (#728)
* Fix dead link in documentation (#733)
* Fix typo in docs/core-manage-versions.md (#722)
* Fix a typo in the `asdf env` command documentation (#717)
* Fix Fish shell documentation (#709)
* Only list asdf dependencies on asdf website (#511, #710)
* Add CODEOWNERS file for GitHub reviews (#705)
* Add unit test for `asdf plugin-add` exit code (#689)

## 0.7.8

Features

* Add support for `post-plugin-add` and `pre-plugin-remove` in plugins. Add configurable command hooks for plugin installation and removal (#670, #683)

    ```shell
    pre_asdf_plugin_remove = echo will remove plugin ${1}
    pre_asdf_plugin_remove_foo = echo will remove plugin foo
    post_asdf_plugin_remove = echo removed plugin ${1}
    post_asdf_plugin_remove_foo = echo removed plugin foo
    ```

* Use different exit code if updates are disabled (#676)

Fixed Bugs

* Make sure extension commands are properly displayed by `asdf help`

  Extension commands are now expected to be inside plugins's `lib/commands/command-*.bash` instead of `bin/command*`.

  This change was made for two reasons: Keep the convention that all files to be sourced by bash should end with
  the `.bash` extension. And the `lib/commands/` directory mirrors the location of asdf own core commands.

  Added tests to make sure `asdf help` properly displays available extension commands.

* Remove automatic `compinit` from asdf.sh (#674, #678)

## 0.7.7

Features

* Add .bash file extension to files executed by Bash (#664)
* Add security policy (#660)

Fixed Bugs

* consistent use of plugin_name (#657)
* Default ZSH_VERSION to empty string (#656)
* Fix support for path version (#654)
* Fix hanging 'asdf update is a noop for non-git repos' test (#644)
* Fix Bash completions for `plugin-add` (#643)
* Fix `--unset` for Fish shell (#640)
* Misc. documentation fixes (#631, #652)
* Defaults to empty ASDF_DATA_DIR (#630)
* Remove shebang lines of sourced scripts (#629)
* Ignore shim directory for executable lookups (#623)
* Fix issue with preset version warning assuming that the shim name and plugin name are the same (#622)

## 0.7.6

Features

* Improve output format of `asdf plugin list all`

  Long plugin names were causing problems with how we used printf.
  Now we use the `column` command to properly render output.

* Now `asdf plugin list` can take both `--urls` and `--refs` options.

  When `--url` is used, we print the plugin's remote origin URL.
  While `--refs` prints the git branch/commit the plugin is at.

* It's now possible to update a plugin to an specific branch/commit.

  `asdf plugin update <name> [git-ref]`

  Checkouts a plugin to the specified `git-ref`. Defaults to `master`

* Now the `asdf plugin test` command can be specified with a plugin commit/branch to test.

  This will help CI checks to actually test the commit they are running for.
  Previously we always used the plugin's `master` branch.

* Subcommand CLI support.

   Users familiar with sub-command aware tools like `git` can now
   use `asdf` commands in the same way. For example:

   `asdf plugin list all` is equivalent to `asdf plugin-list-all`

   This is also the case for plugin extension commands, where the
   plugin name is an asdf main subcommand. ie. Having a `foo` plugin
   you can invoke: `asdf foo bar`

* Make `asdf plugin test` use the new `asdf latest` command. (#541)

   If a plugin version is not given explicitly, we use `asdf latest` to
   obtain the version of plugin to install for testing.

* `asdf --version` displays git revision when asdf_dir is a git clone.

   This will allow better bug reports since people can now include the
   git commit they are using.

* Add support for asdf extension commands.

   Plugins can provide `bin/command*` scripts or executables that will
   be callable using the asdf command line interface.

   See `docs/plugins-create.md` for more info.

* Add support for installing the latest stable version of a tool (#216)

    ```shell
    asdf install python latest
    asdf install python latest:3.7 # installs latest Python 3.7 version
    ```

* Add `asdf latest` command to display the latest stable version of a tool (#575)

    ```shell
    asdf latest python
    asdf latest python 3.7 # displays latest Python 3.7 version
    ```

* Add support for filtering versions returned by `asdf list-all`

    ```shell
    asdf list-all python 3.7 # lists available Python 3.7 versions
    ````

## 0.7.5

Features

* Add AppVeyor config for builds on Windows, for eventual Windows support (#450, #451)
* Add `--unset` flag to shell command (#563)

Fixed Bugs

* Fix multiple version install (#540, #585)
* Handle dashes in executable/shim names properly (#565, #589)
* Fix bug in sed command so `path:...` versions are handled correctly (#559, #591)

## 0.7.4

Features

* Add quite flag to git clone (#546)
* Improve docs for Homebrew (#553, #554)

Fixed Bugs

* Don't include the current directory in `PATH` variable in `asdf env` environment (#543, #560)
* Fix `asdf plugin-test` dependency on Git when installed via Homebrew (#509, #556)

## 0.7.3

Features

* Make `asdf install` check for versions in legacy files (#533, #539)

Fixed Bugs

* Address shellcheck warning and use shell globbing instead of `ls` (#525)

## 0.7.2

Features

* Add unit tests for untested code in asdf.sh and asdf.fish (#286, #507, #508)
* Switched to a maintained version of BATS (#521)

Fixed Bugs

* Don't iterate on output of `ls` (#513)
* Check shims for full tool version so adding new versions to a shim works properly (#517, #524)

## 0.7.1

Features

* Add mksh support
* Add documentation about using multiple versions of the same plugin
* Remove post_COMMAND hooks
* Add `asdf shell` command to set a version for the current shell (#480)
* Ignore comments in .tool-versions (#498, #504)

Fixed Bugs

* Avoid modifying `fish_user_paths`
* Restore support for legacy file version (#484)
* Restore support for multiple versions
* Fix bug when trying to locate shim (#488)
* Run executable using `exec` (#502)

## 0.7.0

Features

* Shims can be invoked directly via `asdf exec <command> [args...]` without requiring to have all shims on path (#374).
* New `asdf env <command>` can be used to print or execute with the env that would be used to execute a shim. (#435)
* Configurable command hooks from `.asdfrc` (#432, #434)
  Suppose a `foo` plugin is installed and provides a `bar` executable,
  The following hooks will be executed when set:

    ```shell
    pre_asdf_install_foo = echo will install foo version ${1}
    post_asdf_install_foo = echo installed foo version ${1}

    pre_asdf_reshim_foo = echo will reshim foo version ${1}
    post_asdf_reshim_foo = echo reshimmed foo version ${1}

    pre_foo_bar = echo about to execute command bar from foo with args: ${@}
    post_foo_bar = echo just executed command bar from foo with args: ${@}

    pre_asdf_uninstall_foo = echo will remove foo version ${1}
    post_asdf_uninstall_foo = echo removed foo version ${1}
    ```
* New shim version meta-data allows shims to not depend on a particular plugin
  nor on its relative executable path (#431)
  Upgrading requires shim re-generation and should happen automatically by `asdf-exec`:
  `rm -rf ~/.asdf/shims/` followed by `asdf reshim`
* Added lots of tests for shim execution.
  We now make sure that shim execution obeys plugins hooks like `list-bin-paths` and
  `exec-path`.
* Shims now are thin wrappers around `asdf exec` that might be faster
  for most common use case: (versions on local .tool-versions file) but fallbacks to
  slower `get_preset_version_for` which takes legacy formats into account.
* Shim exec recommends which plugins or versions to set when command is not found.
* `asdf reshim` without arguments now reshims all installed plugins (#407)
* Add `asdf shim-versions <executable>` to list on which plugins and versions is a command
  available. (#380, #433)
* Add documentation on installing dependencies via Spack (#471)

Fixed Bugs

* Fix `update` command so it doesn't crash when used on Brew installations (#429, #474, #439, #436)

## 0.6.3

Features

* Make `which` command work with any binary included in a plugin installation (#205, #382)
* Add documentation for documentation website (#274, #396, #422, #423, #427, #430)

Fixed Bugs

* Silence errors during tab completion (#404)
* Remove unused asdf shims directory from `PATH` (#408)
* Fix issues with update command that prevented updates for installations in custom locations (#411)
* Fix shellcheck warnings on OSX (#416)
* Add tests for versions set by environment variables (#417, #327)
* Continue `list` output even when version is not found (#419)
* Fixed user paths for fish (#420, #421)
* Custom exec path tests (#324, #424)

## 0.6.2

Fixed Bugs

* Fix `system` logic so shims directory is removed from `PATH` properly (#402, #406)
* Support `.tool-versions` files that don't end in a newline (#403)

## 0.6.1

Features

* Make `where` command default to current version (#389)
* Optimize code for listing all plugins (#388)
* Document `$TRAVIS_BUILD_DIR` in the plugin guide (#386)
* Add `--asdf-tool-version` flag to plugin-test command (#381)
* Add `-p` flag to `local` command (#377)

Fixed Bugs

* Fix behavior of `current` command when multiple versions are set (#401)
* Fix fish shell init code (#392)
* Fix `plugin-test` command (#379)
* Add space before parenthesis in `current` command output (#371)

## 0.6.0

Features

* Add support for `ASDF_DATA_DIR` environment variable (#275, #335, #361, #364, #365)

Fixed Bugs

* Fix `asdf current` so it works when no versions are installed (#368, #353)
* Don't try to install system version (#369, #351)
* Make `resolve_symlink` function work with relative symlinks (#370, #366)
* Fix version changing code so it preserves symlinks (#329, #337)
* Fix ShellCheck warnings (#336)

## 0.5.1

Features

* Better formatting for `asdf list` output (#330, #331)

Fixed Bugs

* Correct environment variable name used for version lookup (#319, #326 #328)
* Remove unnecessary `cd` in `asdf.sh` (#333, #334)
* Correct Fish shell load script (#340)

## 0.5.0

Features

* Changed exit codes for shims so we use codes with special meanings when possible (#305, #310)
* Include plugin name in error message if plugin doesn't exist (#315)
* Add support for custom executable paths (#314)
* `asdf list` with no arguments should list all installed versions of all plugins (#311)

Fixed Bugs

* Print "No version set" message to stderr (#309)
* Fix check for asdf directories in path for Fish shell (#306)

## 0.4.3

Features

* Suggest action when no version is set (#291, #293)

Fixed Bugs

* Fix issue with asdf not always being added to beginning of `$PATH` (#288, #303, #304)
* Fix incorrect `ASDF_CONFIG_FILE` environment variable name (#300)
* Fix `asdf current` so it shows environment variables that are setting versions (#292, 294)

## 0.4.2

Features

* Add support for `ASDF_DEFAULT_TOOL_VERSIONS_FILENAME` environment variable (#201, #228)
* Only add asdf to `PATH` once (#261, #271)
* Add `--urls` flag to `plugin-list` commands (#273)

Fixed Bugs

* Incorrect `grep` command caused version command to look at the wrong tool when reporting the version (#262)

## 0.4.1

Features

* `asdf install` will also search for `.tool-versions` in parent directories (#237)

Fixed Bugs

* bad use of `sed` caused shims and `.tool-versions` to be duplicated with `-e` (#242, #250)
* `asdf list` now outputs ref-versions as used on `.tool-versions` file (#243)
* `asdf update` will explicitly use the `origin` remote when updating tags (#231)
* All code is now linted by shellcheck (#223)
* Add test to fail builds if banned commands are found (#251)

## 0.4.0

Features

* Add CONTRIBUTING guidelines and GitHub issue and pull request templates (#217)
* Add `plugin-list-all` command to list plugins from asdf-plugins repo. (#221)
* `asdf current` shows all current tool versions when given no args (#219)
* Add asdf-plugin-version metadata to shims (#212)
* Add release.sh script to automate release of new versions (#220)

Fixed Bugs

* Allow spaces on path containing the `.tool-versions` file (#224)
* Fixed bug in `--version` functionality so it works regardless of how asdf was installed (#198)

## 0.3.0

Features

* Add `update` command to make it easier to update asdf to the latest release (#172, #180)
* Add support for `system` version to allow passthrough to system installed tools (#55, #182)

Fixed Bugs

* Set `GREP_OPTIONS` and `GREP_COLORS` variables in util.sh so grep is always invoked with the correct settings (#170)
* Export `ASDF_DIR` variable so the Zsh plugin can locate asdf if it's in a custom location (#156)
* Don't add execute permission to files in a plugin's bin directory when adding the plugin (#124, #138, #154)

## 0.2.1

Features

* Determine global tool version even when used outside of home directory (#106)

Fixed Bugs

* Correct reading of `ref:` and `path:` versions (#112)
* Remove shims when uninstalling a version or removing a plugin (#122, #123, #125, #128, #131)
* Add a helpful error message to the install command (#135)

## 0.2.0

Features

* Improve plugin API for legacy file support (#87)
* Unify `asdf local` and `asdf global` version getters as `asdf current` (#83)
* Rename `asdf which` to `asdf current` (#78)

Fixed Bugs

* Fix bug that caused the `local` command to crash when the directory contains whitespace (#90)
* Misc typo corrections (#93, #99)

## 0.1.0

* First tagged release
