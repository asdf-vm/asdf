# Changelog

## [0.18.0](https://github.com/asdf-vm/asdf/compare/v0.17.0...v0.18.0) (2025-06-07)


### Features

* `asdf list` exit with status code of 0 when no versions installed ([#2116](https://github.com/asdf-vm/asdf/issues/2116)) ([e7d5289](https://github.com/asdf-vm/asdf/commit/e7d5289c57894ebbc0f966cb91794efd970377af))


### Bug Fixes

* correct flag handling in commands run by `asdf exec` ([#2115](https://github.com/asdf-vm/asdf/issues/2115)) ([d6cd693](https://github.com/asdf-vm/asdf/commit/d6cd6930cff8e7159cb2f1a57b23bd0ec1faa6ac))
* only return version starting with number when no filter is supplied ([#2120](https://github.com/asdf-vm/asdf/issues/2120)) ([cf29b51](https://github.com/asdf-vm/asdf/commit/cf29b5136bbe481ae3803dbdb78086c808eeef7a))
* print all error output to stderr when shim can't be resolved ([#2109](https://github.com/asdf-vm/asdf/issues/2109)) ([c9049ea](https://github.com/asdf-vm/asdf/commit/c9049ea2fd09fc7958fb1a5a5b44e0670740465b))
* rename tool version filename environment variable for clarity ([#2101](https://github.com/asdf-vm/asdf/issues/2101)) ([e3d6014](https://github.com/asdf-vm/asdf/commit/e3d6014419296281c4156fc65a3e02bb542495a2))
* upgrade urfave/cli to version 3 ([#2105](https://github.com/asdf-vm/asdf/issues/2105)) ([392d09a](https://github.com/asdf-vm/asdf/commit/392d09a8b263a5ef18fd05f27312717bf9baa292))

## [0.17.0](https://github.com/asdf-vm/asdf/compare/v0.16.7...v0.17.0) (2025-05-19)


### Features

* **golang-rewrite:** add support for shim templates resolution ([#2076](https://github.com/asdf-vm/asdf/issues/2076)) ([a3bccea](https://github.com/asdf-vm/asdf/commit/a3bccea5c9b64bf81675efaa5c76d6eb367fd37f))
* log failure to add plugin in "plugin test" ([#2059](https://github.com/asdf-vm/asdf/issues/2059)) ([92de803](https://github.com/asdf-vm/asdf/commit/92de803ff15f1a887f031d570ae6404f008d829d))
* switch back to native git client ([#1998](https://github.com/asdf-vm/asdf/issues/1998)) ([1efa2bb](https://github.com/asdf-vm/asdf/commit/1efa2bbd04b833d0435a15bddd882beb973cfc2d))


### Bug Fixes

* address linter warning ([67581cf](https://github.com/asdf-vm/asdf/commit/67581cf030d4eb39f261acac5e861444fedad7f6))
* correct intersection logic in `shims.FindExecutable` function so ordering of multiple versions is preserved ([#2063](https://github.com/asdf-vm/asdf/issues/2063)) ([083f20a](https://github.com/asdf-vm/asdf/commit/083f20aa3e21cad594b35972ca570eb47e389899))
* correct output of install command when system or path version set ([#2097](https://github.com/asdf-vm/asdf/issues/2097)) ([82d67e3](https://github.com/asdf-vm/asdf/commit/82d67e3242b0ac4d01cccd9712daaae574ce6eca))
* ensures output always ends with a newline when printed ([#2098](https://github.com/asdf-vm/asdf/issues/2098)) ([6f4837e](https://github.com/asdf-vm/asdf/commit/6f4837ea9b82b442fdfa78c3bb315b088e60dc9c))
* handle tilde in env vars ([#2092](https://github.com/asdf-vm/asdf/issues/2092)) ([6da599a](https://github.com/asdf-vm/asdf/commit/6da599a93ad2655c2bf061c038da330ee4413985))
* remove default error action from plugin command ([#2027](https://github.com/asdf-vm/asdf/issues/2027)) ([c376481](https://github.com/asdf-vm/asdf/commit/c376481cb4d1fa1e67dd9ef326381c07c935151d))
* remove unused ForcePrepend option from Go code ([#2089](https://github.com/asdf-vm/asdf/issues/2089)) ([49e9f33](https://github.com/asdf-vm/asdf/commit/49e9f330a719de6bd599b84c90b93e7d7358043c))
* set correct version for go install and make builds ([#2077](https://github.com/asdf-vm/asdf/issues/2077)) ([4c73527](https://github.com/asdf-vm/asdf/commit/4c73527d6323ca41d8ea9a9e78a8db49f3794d16))

## [0.16.7](https://github.com/asdf-vm/asdf/compare/v0.16.6...v0.16.7) (2025-03-25)


### Bug Fixes

* remove comment from first line zsh completion output ([#2035](https://github.com/asdf-vm/asdf/issues/2035)) ([#2037](https://github.com/asdf-vm/asdf/issues/2037)) ([74d7b17](https://github.com/asdf-vm/asdf/commit/74d7b17a1cc9f640cf0f5134416d1cf7a56fe19f))

## [0.16.6](https://github.com/asdf-vm/asdf/compare/v0.16.5...v0.16.6) (2025-03-21)


### Bug Fixes

* correct ASDF_INSTALL_* envvar unset test ([#2006](https://github.com/asdf-vm/asdf/issues/2006)) ([6fbf94a](https://github.com/asdf-vm/asdf/commit/6fbf94a75b8e045eea53038182e376b21a6947e4))
* correct concurrency to align with documentation ([#2014](https://github.com/asdf-vm/asdf/issues/2014)) ([807ea38](https://github.com/asdf-vm/asdf/commit/807ea3883139da48300e72931680431aa35e593d))
* correct handling of `ASDF_FORCE_PREPEND` environment variable ([#2011](https://github.com/asdf-vm/asdf/issues/2011)) ([43a84a0](https://github.com/asdf-vm/asdf/commit/43a84a024faeacb04044c9e2cf20ccbe87ea4263))
* improve zsh completion suggestions ([#2022](https://github.com/asdf-vm/asdf/issues/2022)) ([b1cf58d](https://github.com/asdf-vm/asdf/commit/b1cf58d2bd01c1c2c3662cca6bd8927d68a37258))
* remove filtering from latest-stable call ([#2032](https://github.com/asdf-vm/asdf/issues/2032)) ([6fcdcdf](https://github.com/asdf-vm/asdf/commit/6fcdcdf6df693fec6d643fab54e2d520bd5b539b))
* remove install directory for version when install fails ([#2024](https://github.com/asdf-vm/asdf/issues/2024)) ([932ac46](https://github.com/asdf-vm/asdf/commit/932ac468b7c24c2adef90a293a1f7280a0074cc4))

## [0.16.5](https://github.com/asdf-vm/asdf/compare/v0.16.4...v0.16.5) (2025-03-04)


### Bug Fixes

* always propagate env variables when executing commands ([#1982](https://github.com/asdf-vm/asdf/issues/1982)) ([80265a8](https://github.com/asdf-vm/asdf/commit/80265a8eecedc623cb8cf5cca18ae563e9d4f94c))
* build static binary to improve portability ([#1993](https://github.com/asdf-vm/asdf/issues/1993)) ([45047a6](https://github.com/asdf-vm/asdf/commit/45047a6c451599e718f996fdadbdcea3ecf683fd))
* correct exit status when sub-command does not exist ([#1991](https://github.com/asdf-vm/asdf/issues/1991)) ([3dd0dd3](https://github.com/asdf-vm/asdf/commit/3dd0dd3b475d1c4ddcb6d76248a988be5cceef51)), closes [#1928](https://github.com/asdf-vm/asdf/issues/1928)
* latest version returns latest version ([#1996](https://github.com/asdf-vm/asdf/issues/1996)) ([0ceac7a](https://github.com/asdf-vm/asdf/commit/0ceac7af8c126980901caba4d8daa80900819451))
* preserve files untracked by Git on plugin update ([#1995](https://github.com/asdf-vm/asdf/issues/1995)) ([d4d8db0](https://github.com/asdf-vm/asdf/commit/d4d8db035d9f349bfed513af6976734db18e2c14))
* set correct env vars on recursive calls ([#1989](https://github.com/asdf-vm/asdf/issues/1989)) ([97a91cc](https://github.com/asdf-vm/asdf/commit/97a91cc8d01bda0896a50dff50a162e87fd61e57))
* simplify env vars parsing ([#1988](https://github.com/asdf-vm/asdf/issues/1988)) ([8990b6b](https://github.com/asdf-vm/asdf/commit/8990b6b4ae3c9754f3764289f0d7cf410815d29d)), closes [#1986](https://github.com/asdf-vm/asdf/issues/1986)

## [0.16.4](https://github.com/asdf-vm/asdf/compare/v0.16.3...v0.16.4) (2025-02-19)


### Bug Fixes

* Add a newline delimiter when suggesting versions to install ([#1972](https://github.com/asdf-vm/asdf/issues/1972)) ([38bea71](https://github.com/asdf-vm/asdf/commit/38bea7145495a53c1a6fbad0542a32a4e7937e91))
* correct version resolution order to restore legacy file fallback behavior ([#1956](https://github.com/asdf-vm/asdf/issues/1956)) ([6696d47](https://github.com/asdf-vm/asdf/commit/6696d4702937442842a3643fab31d21a7fd0208f))
* support environment variables with equals sign and newlines in value ([#1977](https://github.com/asdf-vm/asdf/issues/1977)) ([1acf082](https://github.com/asdf-vm/asdf/commit/1acf0824ccfd33f118cb7440970df9e43899a1c1))

## [0.16.3](https://github.com/asdf-vm/asdf/compare/v0.16.2...v0.16.3) (2025-02-17)


### Bug Fixes

* add missing version command ([#1931](https://github.com/asdf-vm/asdf/issues/1931)) ([5339c41](https://github.com/asdf-vm/asdf/commit/5339c413d2fd77e971ed9b7621f0454b96fe3a0d))
* correct formatting of version in "already installed" error message ([df5e283](https://github.com/asdf-vm/asdf/commit/df5e283fb74a63faecd9ab234af1f0c24f1afdcd))
* correct typo in `Upgrading to 0.16.0` documentation ([#1938](https://github.com/asdf-vm/asdf/issues/1938)) ([7e8e5f6](https://github.com/asdf-vm/asdf/commit/7e8e5f60d13b0672e65982e21d7dc864246be8eb))
* don't error if version already installed ([06f8990](https://github.com/asdf-vm/asdf/commit/06f89907b2002db0e53b9bb2acd8ad11935f051c))
* pass environment variables through to `exec-env` callback ([9e6b559](https://github.com/asdf-vm/asdf/commit/9e6b5594080acd4208427505d9018123f1fb1f36))
* repair invalid fish shell completion code ([#1936](https://github.com/asdf-vm/asdf/issues/1936)) ([8388f99](https://github.com/asdf-vm/asdf/commit/8388f992e9be7f21313d8c8e363b43e82e44f207))
* return no error from shims.RemoveAll when shims dir missing ([#1967](https://github.com/asdf-vm/asdf/issues/1967)) ([45c31c9](https://github.com/asdf-vm/asdf/commit/45c31c9761f62a45896f6e45707a60fd0c1f4111))

## [0.16.2](https://github.com/asdf-vm/asdf/compare/v0.16.1...v0.16.2) (2025-02-08)


### Bug Fixes

* correct Bash completion ([#1886](https://github.com/asdf-vm/asdf/issues/1886)) ([fdb1bc7](https://github.com/asdf-vm/asdf/commit/fdb1bc793a06263a0eac8818c14498e23906108a))
* improve completions for Zsh and Fish ([#1912](https://github.com/asdf-vm/asdf/issues/1912)) ([2f806de](https://github.com/asdf-vm/asdf/commit/2f806de830655d9146d25663d74e3fceedcc300f))
* correct help for asdf set command ([#1920](https://github.com/asdf-vm/asdf/issues/1920)) ([554b4ea](https://github.com/asdf-vm/asdf/commit/554b4eaf351c08fed2261715308320838f0c5afb))
* correct help for asdf set command in Bash completion ([#1921](https://github.com/asdf-vm/asdf/issues/1921)) ([63e7dca](https://github.com/asdf-vm/asdf/commit/63e7dcaeae46d6d43ae63db9bf635e227a6ba944))
* improve Zsh completion suggestions ([#1925](https://github.com/asdf-vm/asdf/issues/1925)) ([e190624](https://github.com/asdf-vm/asdf/commit/e190624fa82fb2caf4d56521232de4e873b63118))
* run go tests when go.mod or go.sum change ([#1917](https://github.com/asdf-vm/asdf/issues/1917)) ([6e4a7b5](https://github.com/asdf-vm/asdf/commit/6e4a7b5ad3d6abdbb98faa383bc41643b35ef6bf))
* fix typo ([#1897](https://github.com/asdf-vm/asdf/issues/1897)) ([98ffa86](https://github.com/asdf-vm/asdf/commit/98ffa861e9b64a2e029a0ed26205bfcc81838180))
* update make utils script to set correct version ([892736b](https://github.com/asdf-vm/asdf/commit/892736bf76ac37487cfca75d2cfcc57d5cdec913))
* update urfave/cli to fix cmd output ([#1914](https://github.com/asdf-vm/asdf/issues/1914)) ([3525e9e](https://github.com/asdf-vm/asdf/commit/3525e9ed4edb05f15a15f00378f5336ef29aa2f4))

## [0.16.1](https://github.com/asdf-vm/asdf/compare/v0.16.0...v0.16.1) (2025-02-05)


### Bug Fixes

* correct SliceToMap environment variable parsing function ([#1879](https://github.com/asdf-vm/asdf/issues/1879)) ([e63aec6](https://github.com/asdf-vm/asdf/commit/e63aec61020a907fe5960d74b6d3dbf229214ae0))
* remove old hyphenated command from help ([1f0296a](https://github.com/asdf-vm/asdf/commit/1f0296a3d11a9df0d300ca61f59d097750ab6f1c))
* replace reference to removed subcommands ([#1868](https://github.com/asdf-vm/asdf/issues/1868)) ([0785d35](https://github.com/asdf-vm/asdf/commit/0785d35263b2bd5ad570ee6706e1b38d8dd05422))
* revert change to old Bash help text ([de019fd](https://github.com/asdf-vm/asdf/commit/de019fde849d2f3a258b3f40e5b2004d1973c804))
* use version in home dir when no version found in root dir ([#1883](https://github.com/asdf-vm/asdf/issues/1883)) ([5ae5f76](https://github.com/asdf-vm/asdf/commit/5ae5f769f1042add6219e98633063e76a03e12b9))

## [0.16.0](https://github.com/asdf-vm/asdf/compare/v0.15.0...v0.16.0) (2025-01-30)


### Features

* **Rewrite asdf in Golang** The rewrite in Go was spread across 88 pull requests that are all included in this release. The primary goal of the rewrite was to create a codebase that was faster, simpler and easier to maintain. The rewrite tries to maintain feature parity with the previous version. However, a number of breaking changes were introduced. Some of these were due to the change of language, a few out of a desire to simplify the code, and some to improve the user experience. For the full list of breaking changes and the upgrade guide visit the [Upgrading to 0.16.0 page](https://asdf-vm.com/guide/upgrading-to-v0-16.html#breaking-changes) on the asdf website. **It is highly recommended that you read this guide before upgrading**.

A warning has also been added to the Bash code for asdf in 0.16.0. anyone trying to use asdf as they did in version 0.15.0 and earlier will get a warning message instructing them to follow the upgrade guide.

The full list of pull requests and merge commits for this rewrite are listed below.

   ([3a9f539](https://github.com/asdf-vm/asdf/commit/3a9f539aa092fa7c043661232f8caa154e861c6f)) ([f41ce90](https://github.com/asdf-vm/asdf/commit/f41ce90dc4410da7bb76c5ccf73147759716be07)) ([#1833](https://github.com/asdf-vm/asdf/issues/1833)) ([4f9a5d3](https://github.com/asdf-vm/asdf/commit/4f9a5d3d314bc6a8abd5e14d9c38472055033fa7)) ([d06d71f](https://github.com/asdf-vm/asdf/commit/d06d71f9f6b2fd6069c6fbf27bc7b13b8b0ec5c2)) ([7d5281a](https://github.com/asdf-vm/asdf/commit/7d5281a8a9151d57113ea0dd5d2fea2b07f55228)) ([8ad3472](https://github.com/asdf-vm/asdf/commit/8ad3472abc64d8a07589a16096142b52aeae18af)) ([b40beb6](https://github.com/asdf-vm/asdf/commit/b40beb6039b031d350bd1c621f34d90f23f72765)) ([b23e5a3](https://github.com/asdf-vm/asdf/commit/b23e5a320fd231c4fa55baa3b32d90b55a6ff4f1)) ([bc05110](https://github.com/asdf-vm/asdf/commit/bc0511015920acd8421bbccaead86e2badf0c2ae)) ([477e9d5](https://github.com/asdf-vm/asdf/commit/477e9d57293b8c99bcb184cfc72e064f4b68eda0)) ([6d708b2](https://github.com/asdf-vm/asdf/commit/6d708b280720d2144ae7976229fd5630eeb31eaf)) ([572ed07](https://github.com/asdf-vm/asdf/commit/572ed07f2bdb31f04a7244d1d127594ef9922db0)) ([19a0597](https://github.com/asdf-vm/asdf/commit/19a0597502ebecb0dfe2946fe19d9f9da3d57a18)) ([b33ab64](https://github.com/asdf-vm/asdf/commit/b33ab6463c7825a0d03f82f430cfad18a1e941c8)) ([b966ca6](https://github.com/asdf-vm/asdf/commit/b966ca66271f1be81abee751dec929f97cadfab4)) ([8db188a](https://github.com/asdf-vm/asdf/commit/8db188a702b1a64812fbb6e5832ec74ed47dfb34)) ([3fd4a83](https://github.com/asdf-vm/asdf/commit/3fd4a839757a2646054f2d86f487731e0715eeaa)) ([09d06ff](https://github.com/asdf-vm/asdf/commit/09d06ff125107c19a24043e52cf60b378b8b4c3b)) ([d2afb85](https://github.com/asdf-vm/asdf/commit/d2afb85eb80bce85e79c9c0d91ad3103a7f985f0)) ([778ab34](https://github.com/asdf-vm/asdf/commit/778ab34a6f47ac913a0ebc5035d74bfbb3744ebe)) ([9f09f78](https://github.com/asdf-vm/asdf/commit/9f09f78ec06b28bd90d7cdd42762acc1e18011c7)) ([6568891](https://github.com/asdf-vm/asdf/commit/65688915a5d6816b15acf7332d22920d10e8d99a)) ([771f184](https://github.com/asdf-vm/asdf/commit/771f18493fcc8684f02373b2f03750937016f51a)) ([8313ebc](https://github.com/asdf-vm/asdf/commit/8313ebca2d2305b8e176286ae0a43b0359d78059)) ([be52d8f](https://github.com/asdf-vm/asdf/commit/be52d8f39c3aa253496c5469963cd0ecc995d19c)) ([c2e5ee6](https://github.com/asdf-vm/asdf/commit/c2e5ee652532f54aaed7e93796f7239a2a333446)) ([9097696](https://github.com/asdf-vm/asdf/commit/9097696a4fa5ad7efeb383509ecce16125df3cbf)) ([ad0907a](https://github.com/asdf-vm/asdf/commit/ad0907a74df1edf42e7c72ecba96ea52e3de2bcf)) ([2b02f51](https://github.com/asdf-vm/asdf/commit/2b02f51fa1acb2090713f6dfa70903281d28735a)) ([c480044](https://github.com/asdf-vm/asdf/commit/c4800443bd805afd1878891c56108366f3faba0c)) ([26b91aa](https://github.com/asdf-vm/asdf/commit/26b91aa8288787e552dbc50a1c2234ad2264205c)) ([202cdae](https://github.com/asdf-vm/asdf/commit/202cdae831b4909280e0f19ff77bbe4acaec36b4)) ([325cd33](https://github.com/asdf-vm/asdf/commit/325cd3334b3898cbd084ac3b3686458cc92b613e)) ([07b5813](https://github.com/asdf-vm/asdf/commit/07b5813566431ce9f6245e884fe86dd13ad1c195)) ([822e14c](https://github.com/asdf-vm/asdf/commit/822e14c561ab1df74f091bb46bcb340ae9c2bda6)) ([53cd454](https://github.com/asdf-vm/asdf/commit/53cd4544741cab2e58ca7ea8aa36c9c28890b0a1)) ([9f6a65f](https://github.com/asdf-vm/asdf/commit/9f6a65f5dda41d25a9e894ff6a8482810fd6dec8)) ([bd7ab9a](https://github.com/asdf-vm/asdf/commit/bd7ab9ae0844c4c9e41760661a555bab13509752)) ([b6ec89f](https://github.com/asdf-vm/asdf/commit/b6ec89f95f6afedbbdb2daaf4c3d2f67f50f0cf1)) ([162cb8e](https://github.com/asdf-vm/asdf/commit/162cb8eceed53f58c20c547d29ca8068e411ce64)) ([d94bace](https://github.com/asdf-vm/asdf/commit/d94baceb184b8a501a8eb1fd2cd33ca75bf962d9)) ([e7df5ff](https://github.com/asdf-vm/asdf/commit/e7df5ff3253b6caba8ceef6b0754d17fcb765a9b)) ([369beeb](https://github.com/asdf-vm/asdf/commit/369beebab9c80197eb877660add870c0a6be5bda)) ([#1829](https://github.com/asdf-vm/asdf/issues/1829)) ([f68b29b](https://github.com/asdf-vm/asdf/commit/f68b29bd508cfe993d4926377891d0a3e902f2ef)) ([26a3815](https://github.com/asdf-vm/asdf/commit/26a38159483588cd0143b58272f42c96e127d265)) ([ccc98ad](https://github.com/asdf-vm/asdf/commit/ccc98ad4e997b73dcc1e9d6839a17a539c5ec649)) ([447acd1](https://github.com/asdf-vm/asdf/commit/447acd13d1225e2e9ef80ae853c5da02fca034c3)) ([72c20b1](https://github.com/asdf-vm/asdf/commit/72c20b1b51d223dd6633f279258cb8bc54eb4661)) ([924eecf](https://github.com/asdf-vm/asdf/commit/924eecfa6af25f59162e3f35b913a1d0247bd34f)) ([f5a5967](https://github.com/asdf-vm/asdf/commit/f5a59677df42f990529bd8a1668fcfea353ea4a0)) ([3af0291](https://github.com/asdf-vm/asdf/commit/3af02913169abf9049933abc4d99406687d743c3)) ([9ed4216](https://github.com/asdf-vm/asdf/commit/9ed4216525a2076b84e9e5fc6d454746a3b4d825)) ([b9e79e6](https://github.com/asdf-vm/asdf/commit/b9e79e64564ad5a94c9d435458e1a57053744b8d)) ([626bde0](https://github.com/asdf-vm/asdf/commit/626bde0a9785e400eaeb2fa72fb11fff6102b458)) ([f639f8a](https://github.com/asdf-vm/asdf/commit/f639f8a4d0a3fcc3cc175def3b3b2d1ebdac1ade)) ([c0963a3](https://github.com/asdf-vm/asdf/commit/c0963a38a62e61586ef0dd34ea568d23345e3739)) ([cb49b64](https://github.com/asdf-vm/asdf/commit/cb49b64a5adb8944acff0c03e617df0a0f39453c)) ([f74efbf](https://github.com/asdf-vm/asdf/commit/f74efbf1bff5d7489f86f2f568eba2667d95645e)) ([15e1f06](https://github.com/asdf-vm/asdf/commit/15e1f06f3751c9b72deea5cbad587140ba03c645)) ([620c0d8](https://github.com/asdf-vm/asdf/commit/620c0d87e8bf1e1c99a5772c9103fa017e75f487)) ([518a0fa](https://github.com/asdf-vm/asdf/commit/518a0fa4422cff1625cb7b676f40c4bc0a42eed9)) ([5d5d04f](https://github.com/asdf-vm/asdf/commit/5d5d04fbb7a41c83ae5031182d7d671fae434cb5)) ([2fc8006](https://github.com/asdf-vm/asdf/commit/2fc80064902a3b467a82466add1db186a99f075a)) ([c859384](https://github.com/asdf-vm/asdf/commit/c8593842eeb2a3eae74af7747afc62fa406a5b54)) ([2951011](https://github.com/asdf-vm/asdf/commit/2951011090a2a8ac3f42d54198a2447213171c38)) ([c5092c6](https://github.com/asdf-vm/asdf/commit/c5092c6dbfce3614f3de2db08afaa6fcb8b7792e)) ([3f9744d](https://github.com/asdf-vm/asdf/commit/3f9744df0fd8b23684ef2c705642232c5d2151af)) ([985c181](https://github.com/asdf-vm/asdf/commit/985c181118b39bb555a2bd2a1cdbf111a25bd512)) ([18e21c9](https://github.com/asdf-vm/asdf/commit/18e21c90284be35fa01e957b49336ffac515e19b)) ([0058988](https://github.com/asdf-vm/asdf/commit/005898800bded840fa7dd9b62a0c60a93c124c8c)) ([#1820](https://github.com/asdf-vm/asdf/issues/1820)) ([c3bd8fe](https://github.com/asdf-vm/asdf/commit/c3bd8feccd2e4589bc905ccf6b1bcd8dc74f4f37)) ([8394e85](https://github.com/asdf-vm/asdf/commit/8394e858fee419ed38833fa953b122fe04754830)) ([5266ba5](https://github.com/asdf-vm/asdf/commit/5266ba581ddf5f96de2d20391e340bb4f7c123c4)) ([3155dc3](https://github.com/asdf-vm/asdf/commit/3155dc374e9cbea6d2d792fef08914124320a292)) ([7dfa8b4](https://github.com/asdf-vm/asdf/commit/7dfa8b40ae5e557b90fb7917bc86a569cf2bd0a6)) ([5a24864](https://github.com/asdf-vm/asdf/commit/5a2486463238e2473aab739520793011267be19f)) ([80ac9bb](https://github.com/asdf-vm/asdf/commit/80ac9bb51c684c04829328c28a06aa1f1f67a8f2)) ([#1849](https://github.com/asdf-vm/asdf/issues/1849)) ([8b1b024](https://github.com/asdf-vm/asdf/commit/8b1b024f51b166bf29481162fa57e5752d0d9300)) ([1b3c426](https://github.com/asdf-vm/asdf/commit/1b3c42699a30b6bcc7295d3f433dad9cd520f130)) ([163d6b4](https://github.com/asdf-vm/asdf/commit/163d6b4b462954a2f52b6a1b9e09faa806292260)) ([87d3c06](https://github.com/asdf-vm/asdf/commit/87d3c06cf5dc859dab4d1af3dec290ed49651b67)) ([3f17a80](https://github.com/asdf-vm/asdf/commit/3f17a80fbe34ee68a3d5580798374caf1a7bc4ae)) ([#1841](https://github.com/asdf-vm/asdf/issues/1841)) ([251812b](https://github.com/asdf-vm/asdf/commit/251812bfd58a768c4a51b82c0f5f88601abfd84c)) ([#1852](https://github.com/asdf-vm/asdf/issues/1852)) ([78a00fc](https://github.com/asdf-vm/asdf/commit/78a00fc90345bd77d83bb9b2b61f85756fceb1a6)) ([6b45a5e](https://github.com/asdf-vm/asdf/commit/6b45a5e5f74f60a22fd20b331163f5e5d6a3881c)) ([2a31caf](https://github.com/asdf-vm/asdf/commit/2a31cafd38128be86696c0a46e0223a95b8129fe)) ([7439ea9](https://github.com/asdf-vm/asdf/commit/7439ea916829f7c3f1f2932fa17b3d2848c2dbe7)) ([88af4ee](https://github.com/asdf-vm/asdf/commit/88af4eea00c395407a4b904e80e307ad864a6535))

### Bug Fixes

* bash command set end of line LF ([#1847](https://github.com/asdf-vm/asdf/issues/1847)) ([8211421](https://github.com/asdf-vm/asdf/commit/8211421f4e0d1f62d2d2b7436f9070040231fcbd))

## [0.15.0](https://github.com/asdf-vm/asdf/compare/v0.14.1...v0.15.0) (2024-12-18)


### Features

* golang-rewrite: remove `asdf update` command to prepare for Go version ([#1806](https://github.com/asdf-vm/asdf/issues/1806)) ([15571a2](https://github.com/asdf-vm/asdf/commit/15571a2d28818644673bbaf0fcf7d1d9e342cda4))


### Patches

* completions: Address two Bash completion bugs ([#1770](https://github.com/asdf-vm/asdf/issues/1770)) ([ebdb229](https://github.com/asdf-vm/asdf/commit/ebdb229ce68979a18dae5c0922620b860c56b22f))
* make plugin-test work on alpine linux ([#1778](https://github.com/asdf-vm/asdf/issues/1778)) ([f5a1f3a](https://github.com/asdf-vm/asdf/commit/f5a1f3a0a8bb50796f6ccf618d2bf4cf3bdea097))
* nushell: nushell spread operator ([#1777](https://github.com/asdf-vm/asdf/issues/1777)) ([a0ce37b](https://github.com/asdf-vm/asdf/commit/a0ce37b89bd5eb4ddaa806f96305ee99a8c5d365))
* nushell: Use correct env var for shims dir ([#1742](https://github.com/asdf-vm/asdf/issues/1742)) ([2f07629](https://github.com/asdf-vm/asdf/commit/2f0762991c35da933b81ba6ab75457a504deedbb))
* when download path got removed, it should use -f to force delete the download files ([#1746](https://github.com/asdf-vm/asdf/issues/1746)) ([221507f](https://github.com/asdf-vm/asdf/commit/221507f1c0288f0df13315a7f0f2c0a7bc39e7c2))


### Documentation

* add Korean translation ([#1757](https://github.com/asdf-vm/asdf/issues/1757)) ([9e16306](https://github.com/asdf-vm/asdf/commit/9e16306f42b4bbffd62779aaebb9cbbc9ba59007))
* propose edits for tiny typographical/grammatical errors ([#1747](https://github.com/asdf-vm/asdf/issues/1747)) ([d462b55](https://github.com/asdf-vm/asdf/commit/d462b55ec9868eeaddba4b70850aba908236dd93))
* split Lint and Test badges for title asdf in `README.MD` ([#1725](https://github.com/asdf-vm/asdf/issues/1725)) ([c778ea1](https://github.com/asdf-vm/asdf/commit/c778ea1deca19d8ccd91253c2f206a6b51a0a9b1))
* Update Japanese(ja-jp) Translations ([#1715](https://github.com/asdf-vm/asdf/issues/1715)) ([bd19e4c](https://github.com/asdf-vm/asdf/commit/bd19e4cbdc2f0a9380dbdfcec46584d619e8ed56))

## [0.14.1](https://github.com/asdf-vm/asdf/compare/v0.14.0...v0.14.1) (2024-08-15)


### Patches

* Only display the "can't keep downloads" warning when asked to keep downloads ([#1756](https://github.com/asdf-vm/asdf/issues/1756)) ([44f3efb](https://github.com/asdf-vm/asdf/commit/44f3efb63b7517520f4610d504d30783a85c9d79))

## [0.14.0](https://github.com/asdf-vm/asdf/compare/v0.13.1...v0.14.0) (2024-01-19)


### ⚠ BREAKING CHANGES

* Enable `pipefail` ([#1608](https://github.com/asdf-vm/asdf/issues/1608))

### Patches

* `plugin test` git-ref to use plugin repo default branch ([#1694](https://github.com/asdf-vm/asdf/issues/1694)) ([6d8cf9d](https://github.com/asdf-vm/asdf/commit/6d8cf9d44b3d985ac59f1eac827c5275392f90fd))
* avoid mention of `ASDF_NU_DIR` ([#1660](https://github.com/asdf-vm/asdf/issues/1660)) ([dfea89c](https://github.com/asdf-vm/asdf/commit/dfea89ccc703f3ef5a87c4b85726456d70167d89))
* Enable `pipefail` ([#1608](https://github.com/asdf-vm/asdf/issues/1608)) ([4085e55](https://github.com/asdf-vm/asdf/commit/4085e5542bac824ea124610ad247c2f90d1b8d93))
* **fish:** use PATH instead of fish_user_paths ([#1709](https://github.com/asdf-vm/asdf/issues/1709)) ([5327697](https://github.com/asdf-vm/asdf/commit/53276973f7c99695cd9a28b04c010b006d7f60ca))
* list `asdf version` command under help.txt UTILS section ([#1673](https://github.com/asdf-vm/asdf/issues/1673)) ([240a5fb](https://github.com/asdf-vm/asdf/commit/240a5fbdea1de055672d02f83db1de990ea2bf83))
* **nushell:** Use `def --env` instead of `def-env` ([#1681](https://github.com/asdf-vm/asdf/issues/1681)) ([3b8f400](https://github.com/asdf-vm/asdf/commit/3b8f400c3e628851286bfebd8da5bc7ab45cd676))
* plugin extension commands to not require `bin/` directory ([#1643](https://github.com/asdf-vm/asdf/issues/1643)) ([61420ad](https://github.com/asdf-vm/asdf/commit/61420ad90829b2c9bf1ca16681a2eb652adcc755))
* use universal scope for fish_user_paths ([#1699](https://github.com/asdf-vm/asdf/issues/1699)) ([0ffee72](https://github.com/asdf-vm/asdf/commit/0ffee7224bc00a917ceaea689c6268fd1f03bd62))
* warn if plugin does not support keeping downloads if configured ([#1644](https://github.com/asdf-vm/asdf/issues/1644)) ([19515ed](https://github.com/asdf-vm/asdf/commit/19515eda3b91167b0d76c35ffc4402de688007e0))


### Documentation

* add Japanese translation ([#1667](https://github.com/asdf-vm/asdf/issues/1667)) ([2b9bec7](https://github.com/asdf-vm/asdf/commit/2b9bec7710cd18e51a01652e1f58cc309baf2fd7))
* fix some pt-br spelling ([#1640](https://github.com/asdf-vm/asdf/issues/1640)) ([0c7c41a](https://github.com/asdf-vm/asdf/commit/0c7c41ab44d3a42a9e57e3d20a646569c2eacfdc))
* fix typo "node version" filename ([#1679](https://github.com/asdf-vm/asdf/issues/1679)) ([fad23bc](https://github.com/asdf-vm/asdf/commit/fad23bc9f4d38747f28d6708ab01689749030063))
* fix typo ([#1670](https://github.com/asdf-vm/asdf/issues/1670)) ([5737fa3](https://github.com/asdf-vm/asdf/commit/5737fa316eab01c4033565eacf678222cd861f8d))
* Improve `.asdfrc` plugin hook documentation ([#1661](https://github.com/asdf-vm/asdf/issues/1661)) ([8fbf9a3](https://github.com/asdf-vm/asdf/commit/8fbf9a396bd4a5b71ec7cf215d12040fb5365d6a))

## [0.13.1](https://github.com/asdf-vm/asdf/compare/v0.13.0...v0.13.1) (2023-09-12)


### Patches

* **fish:** use builtin realpath over system one ([#1637](https://github.com/asdf-vm/asdf/issues/1637)) ([5ac3032](https://github.com/asdf-vm/asdf/commit/5ac30328a7bbd1a8d974bb5fb1f14d8bd2d1e03f))

## [0.13.0](https://github.com/asdf-vm/asdf/compare/v0.12.0...v0.13.0) (2023-09-11)


### ⚠ BREAKING CHANGES

* `plugin list` exit code 0 when no plugins are installed ([#1597](https://github.com/asdf-vm/asdf/issues/1597))
* 0 exit code for success when adding an existing plugin ([#1598](https://github.com/asdf-vm/asdf/issues/1598))
* **fish:** don't resolve symlinks for ASDF_DIR ([#1583](https://github.com/asdf-vm/asdf/issues/1583))

### Features

* add plugin location when update the plugin ([#1602](https://github.com/asdf-vm/asdf/issues/1602)) ([36c7024](https://github.com/asdf-vm/asdf/commit/36c7024baa4b829b3629b4e0430157266d354158))


### Patches

* `plugin list` exit code 0 when no plugins are installed ([#1597](https://github.com/asdf-vm/asdf/issues/1597)) ([a029c00](https://github.com/asdf-vm/asdf/commit/a029c007503f2eec911a0c836e8622bb38c5e065))
* 0 exit code for success when adding an existing plugin ([#1598](https://github.com/asdf-vm/asdf/issues/1598)) ([4dd1904](https://github.com/asdf-vm/asdf/commit/4dd190466a9855dac300ce691e66a7629ef37b82))
* **fish:** don't resolve symlinks for ASDF_DIR ([#1583](https://github.com/asdf-vm/asdf/issues/1583)) ([d1a563d](https://github.com/asdf-vm/asdf/commit/d1a563dcc0107d5c631f73b114044898b5cadcf9))
* improve lint and test scripts ([#1607](https://github.com/asdf-vm/asdf/issues/1607)) ([b320803](https://github.com/asdf-vm/asdf/commit/b3208031204aabad6e85346155baacab16862da8))
* Make asdf.fish compatible with Fish 3.1.2 ([#1590](https://github.com/asdf-vm/asdf/issues/1590)) ([e83d71e](https://github.com/asdf-vm/asdf/commit/e83d71e43f525453994eb4cfda8ad66f8b914529))
* no longer write temporary files to home directory ([#1592](https://github.com/asdf-vm/asdf/issues/1592)) ([624604a](https://github.com/asdf-vm/asdf/commit/624604a8626dc6006d78121d4cf0f6c920449c56))
* nushell language syntax update ([#1624](https://github.com/asdf-vm/asdf/issues/1624)) ([0ddab5d](https://github.com/asdf-vm/asdf/commit/0ddab5dfaf28ad97c84a6aa56b08ccc212e07b4d))
* set default shell version values on POSIX entrypoint ([#1594](https://github.com/asdf-vm/asdf/issues/1594)) ([4d5f22d](https://github.com/asdf-vm/asdf/commit/4d5f22ddb89ce53e24b1ab1cbefce3be95238a19))
* warn when any ./lib/commands are marked as executable ([#1593](https://github.com/asdf-vm/asdf/issues/1593)) ([2043a09](https://github.com/asdf-vm/asdf/commit/2043a09574bdfdfcf2daf2fdb3bff2d9d2dad64e))


### Documentation

* `bin/latest-stable` empty query is set to default ([#1591](https://github.com/asdf-vm/asdf/issues/1591)) ([299dc97](https://github.com/asdf-vm/asdf/commit/299dc97a5b63d8afe1a0bba03e32dddfb7fb8e51))
* migrate to VitePress from VuePress ([#1578](https://github.com/asdf-vm/asdf/issues/1578)) ([5133819](https://github.com/asdf-vm/asdf/commit/5133819a77aaa393def347bfecb1c442ece4c7f8))
* upgrade deps & fix breaking changes ([446f8c5](https://github.com/asdf-vm/asdf/commit/446f8c5f947cc5f30f03403c2cfe4dec71b0a494))

## [0.12.0](https://github.com/asdf-vm/asdf/compare/v0.11.3...v0.12.0) (2023-06-09)


### ⚠ BREAKING CHANGES

* Remove files containing only `asdf` wrapper functions ([#1525](https://github.com/asdf-vm/asdf/issues/1525))
* align Fish entrypoint behaviour with other shells ([#1524](https://github.com/asdf-vm/asdf/issues/1524))
* do not remove items from PATH in POSIX entrypoint ([#1521](https://github.com/asdf-vm/asdf/issues/1521))
* rework POSIX entrypoint for greater shell support ([#1480](https://github.com/asdf-vm/asdf/issues/1480))

### Features

* Support configurable `ASDF_CONCURRENCY` ([#1532](https://github.com/asdf-vm/asdf/issues/1532)) ([684f4f0](https://github.com/asdf-vm/asdf/commit/684f4f058f24cc418f77825a59a22bacd16a9bee))
* Support PowerShell Core ([#1522](https://github.com/asdf-vm/asdf/issues/1522)) ([213aa22](https://github.com/asdf-vm/asdf/commit/213aa22378cf0ecf5b1924f1bfc4fee43338255a))


### Documentation

* Add Nushell installation instructions for all languages ([#1519](https://github.com/asdf-vm/asdf/issues/1519)) ([6a6c539](https://github.com/asdf-vm/asdf/commit/6a6c539f4a21fdb863fd938edd94ac3bdced349b))
* fix `ASDF_${LANG}_VERSION` usage ([#1528](https://github.com/asdf-vm/asdf/issues/1528)) ([63f422b](https://github.com/asdf-vm/asdf/commit/63f422b4c7afcf53ef72002e39967eb9ca2da2a9))
* fix Nushell-Homebrew setup instructions ([#1495](https://github.com/asdf-vm/asdf/issues/1495)) ([49e541a](https://github.com/asdf-vm/asdf/commit/49e541a29ff7a2f35917a4544a8b9adbc02bb1b4))
* fix uninstall instructions for Fish Shell ([#1547](https://github.com/asdf-vm/asdf/issues/1547)) ([a1e858d](https://github.com/asdf-vm/asdf/commit/a1e858d2542691adabf9b066add86f16e759a90c))
* Improve wording of env vars section ([#1514](https://github.com/asdf-vm/asdf/issues/1514)) ([ec3eb2d](https://github.com/asdf-vm/asdf/commit/ec3eb2d64f0531be86d10e1202a92f6b7820e294))
* verbose plugin create command details ([#1445](https://github.com/asdf-vm/asdf/issues/1445)) ([8108ca6](https://github.com/asdf-vm/asdf/commit/8108ca6d7e5f34b9b9723f945a9c4b137f2e10ef))


### Patches

* `asdf info` show BASH_VERSION & all asdf envs ([#1513](https://github.com/asdf-vm/asdf/issues/1513)) ([a1b5eee](https://github.com/asdf-vm/asdf/commit/a1b5eeec1caf605c0e4c80748703b9e227b57aeb))
* align Fish entrypoint behaviour with other shells ([#1524](https://github.com/asdf-vm/asdf/issues/1524)) ([8919f40](https://github.com/asdf-vm/asdf/commit/8919f4009ea233c32298911b28ceb879e2dbc675))
* assign default values to all internal variables ([#1518](https://github.com/asdf-vm/asdf/issues/1518)) ([86477ee](https://github.com/asdf-vm/asdf/commit/86477ee8dea14ab63faf7132133304855a647fde))
* Better handling with paths that include spaces ([#1485](https://github.com/asdf-vm/asdf/issues/1485)) ([bbcbddc](https://github.com/asdf-vm/asdf/commit/bbcbddcdd4ffa0f49c3772b66d87331420fa5727))
* create install directory with `mkdir -p` ([#1563](https://github.com/asdf-vm/asdf/issues/1563)) ([d6185a2](https://github.com/asdf-vm/asdf/commit/d6185a21207e0ac45e69499883dad5e2b585c1b6))
* do not remove items from PATH in POSIX entrypoint ([#1521](https://github.com/asdf-vm/asdf/issues/1521)) ([b6d0ca2](https://github.com/asdf-vm/asdf/commit/b6d0ca28d5fd2b63c7da67b127e6c2a0e01b2670))
* enforce consistent shell redirection format ([#1533](https://github.com/asdf-vm/asdf/issues/1533)) ([1bc205e](https://github.com/asdf-vm/asdf/commit/1bc205e8aa61287c766c673acb8f0d4f9c6ee249))
* improve readability of the non-set `nullglob` guard ([#1545](https://github.com/asdf-vm/asdf/issues/1545)) ([f273612](https://github.com/asdf-vm/asdf/commit/f273612155188f62cf8daf584d5581cd4214daf4))
* Introduce `ASDF_FORCE_PREPEND` variable on POSIX entrypoint ([#1560](https://github.com/asdf-vm/asdf/issues/1560)) ([5b7d0fe](https://github.com/asdf-vm/asdf/commit/5b7d0fea0a10681d89dd7bf4010e0a39e6696841))
* lint & style errors in `bin/asdf` ([#1516](https://github.com/asdf-vm/asdf/issues/1516)) ([13c0e2f](https://github.com/asdf-vm/asdf/commit/13c0e2fab0e9ad4dccf72b6f5586fb32458b8709))
* Nushell plugin list --urls ([#1507](https://github.com/asdf-vm/asdf/issues/1507)) ([9363fb2](https://github.com/asdf-vm/asdf/commit/9363fb2f72e7fa08d3580b22d465af48a7d37031))
* nushell plugin list all ([#1501](https://github.com/asdf-vm/asdf/issues/1501)) ([#1502](https://github.com/asdf-vm/asdf/issues/1502)) ([c5b8b3c](https://github.com/asdf-vm/asdf/commit/c5b8b3c128b48e1531f6d03d2083435f413a4738))
* Remove files containing only `asdf` wrapper functions ([#1525](https://github.com/asdf-vm/asdf/issues/1525)) ([00fee78](https://github.com/asdf-vm/asdf/commit/00fee78423de0e399f5705bb483e599e39b707c9))
* remove leading asterick in Fish completion ([#1543](https://github.com/asdf-vm/asdf/issues/1543)) ([198ced5](https://github.com/asdf-vm/asdf/commit/198ced50327b20b136cb6ec165610d37334a2962))
* rename internal function `asdf_tool_versions_filename` ([#1544](https://github.com/asdf-vm/asdf/issues/1544)) ([b36ec73](https://github.com/asdf-vm/asdf/commit/b36ec7338654abc3773314147540dfa8297b48b8))
* rename internal plugin repository functions ([#1537](https://github.com/asdf-vm/asdf/issues/1537)) ([5367f1f](https://github.com/asdf-vm/asdf/commit/5367f1f09079070c7b47551dc453c686991564a0))
* rework POSIX entrypoint for greater shell support ([#1480](https://github.com/asdf-vm/asdf/issues/1480)) ([3379af8](https://github.com/asdf-vm/asdf/commit/3379af845ed2e281703bc0e9e4f388a7845edc2a))
* support `asdf shim-versions` completions in fish & bash ([#1554](https://github.com/asdf-vm/asdf/issues/1554)) ([99623d7](https://github.com/asdf-vm/asdf/commit/99623d7eac0fe17e330a950c71b7ba378f656b2c))
* Typo in POSIX entrypoint ([#1562](https://github.com/asdf-vm/asdf/issues/1562)) ([6b2ebf5](https://github.com/asdf-vm/asdf/commit/6b2ebf575ff98d3970b518de04238d30804a40d1))
* warn if `.tool-versions` or asdfrc contains carriage returns ([#1561](https://github.com/asdf-vm/asdf/issues/1561)) ([097f773](https://github.com/asdf-vm/asdf/commit/097f7733d67aaf8d0dca1c793407babbdf6f8394))

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
* Remove unnecessary backslashes ([#1384](https://github.com/asdf-vm/asdf/issues/1384)) ([15faf93](https://github.com/asdf-vm/asdf/commit/15faf93a0d3615834e550ea1562fb6b8cee5a205))
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
