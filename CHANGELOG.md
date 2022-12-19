# Semantic Versioning Changelog

## [1.9.1](https://github.com/afewell/ovathetap/compare/v1.9.0...v1.9.1) (2022-12-19)


### Bug Fixes

* add export -f <function name> statement to all functions [#33](https://github.com/afewell/ovathetap/issues/33) ([f6a90f2](https://github.com/afewell/ovathetap/commit/f6a90f2faa8d70862dd2a2917f1ab5af8b1bf30d))

# [1.9.0](https://github.com/afewell/ovathetap/compare/v1.8.7...v1.9.0) (2022-12-19)


### Features

* add docker proxy config to fix rate limiting issue to resolve [#30](https://github.com/afewell/ovathetap/issues/30) ([0e2675d](https://github.com/afewell/ovathetap/commit/0e2675daa0bf639aa603d8ea670bb39fe0330a62))

## [1.8.7](https://github.com/afewell/ovathetap/compare/v1.8.6...v1.8.7) (2022-12-19)


### Bug Fixes

* secrets handling solution to resolve [#29](https://github.com/afewell/ovathetap/issues/29) ([ef480b8](https://github.com/afewell/ovathetap/commit/ef480b89a81f60c38d4771aea761f377259423db))

## [1.8.6](https://github.com/afewell/ovathetap/compare/v1.8.5...v1.8.6) (2022-12-19)


### Bug Fixes

* add commands to automatically add correct ca_cert_data: value to tap-values.yaml to resolve [#28](https://github.com/afewell/ovathetap/issues/28) and added yq to resolve [#27](https://github.com/afewell/ovathetap/issues/27) ([f0e08d5](https://github.com/afewell/ovathetap/commit/f0e08d5e8cd8b83e639acaf54c356c7d7694c4e4))

## [1.8.5](https://github.com/afewell/ovathetap/compare/v1.8.4...v1.8.5) (2022-12-19)


### Bug Fixes

* add kubectl completion to persist, with support for k alias to resolve [#26](https://github.com/afewell/ovathetap/issues/26) ([ac6d7ee](https://github.com/afewell/ovathetap/commit/ac6d7eef6b8030b20aaa955d18f7009387077da6))

## [1.8.4](https://github.com/afewell/ovathetap/compare/v1.8.3...v1.8.4) (2022-12-19)


### Bug Fixes

* Update default kubernetes version to 1.24.8 to resolve [#23](https://github.com/afewell/ovathetap/issues/23) ([89035d3](https://github.com/afewell/ovathetap/commit/89035d3119978726f5a533c71286c766dd75f896))

## [1.8.3](https://github.com/afewell/ovathetap/compare/v1.8.2...v1.8.3) (2022-12-19)


### Bug Fixes

* Update script to configure hostusername account with passwordless sudo to resolve [#22](https://github.com/afewell/ovathetap/issues/22) ([d4fdcf8](https://github.com/afewell/ovathetap/commit/d4fdcf831e78f534f6d9eaa766774c9cb6b10ec6))

## [1.8.2](https://github.com/afewell/ovathetap/compare/v1.8.1...v1.8.2) (2022-12-19)


### Bug Fixes

* move current instructions from tap1_3install_notes file to main readme to resolve [#21](https://github.com/afewell/ovathetap/issues/21) ([d76ad4a](https://github.com/afewell/ovathetap/commit/d76ad4ad35a1d406aea90a6c8752ff155c1b400c))

## [1.8.1](https://github.com/afewell/ovathetap/compare/v1.8.0...v1.8.1) (2022-12-19)


### Bug Fixes

* refactor taphostprep-1.sh to include an install-all optionto resolve [#20](https://github.com/afewell/ovathetap/issues/20) ([3c867a8](https://github.com/afewell/ovathetap/commit/3c867a806b8a2ac7186cc5b66fcfc329df171f2c))

# [1.8.0](https://github.com/afewell/ovathetap/compare/v1.7.0...v1.8.0) (2022-12-19)


### Features

* reafactoring ... multiple updates to resolve [#18](https://github.com/afewell/ovathetap/issues/18) and [#19](https://github.com/afewell/ovathetap/issues/19) ([bbd4030](https://github.com/afewell/ovathetap/commit/bbd403080c5dfb9c798efcfd30594069d5cbea20))

# [1.7.0](https://github.com/afewell/ovathetap/compare/v1.6.1...v1.7.0) (2022-12-18)


### Features

* multiple updates to resolve [#12](https://github.com/afewell/ovathetap/issues/12), [#13](https://github.com/afewell/ovathetap/issues/13), [#14](https://github.com/afewell/ovathetap/issues/14), [#15](https://github.com/afewell/ovathetap/issues/15) and [#16](https://github.com/afewell/ovathetap/issues/16) ([c5ea25b](https://github.com/afewell/ovathetap/commit/c5ea25b338b7030859db5fdee47828c58b1b7fee))

## [1.6.1](https://github.com/afewell/ovathetap/compare/v1.6.0...v1.6.1) (2022-12-17)


### Bug Fixes

* Add harbor to taphostprep-2 to resolve [#11](https://github.com/afewell/ovathetap/issues/11) ([010e026](https://github.com/afewell/ovathetap/commit/010e0260d2e04cf868abd3154657469f781a5c11))

# [1.6.0](https://github.com/afewell/ovathetap/compare/v1.5.0...v1.6.0) (2022-12-17)


### Features

* create initial version of taphostprep-2.sh to resolve [#10](https://github.com/afewell/ovathetap/issues/10) ([e272132](https://github.com/afewell/ovathetap/commit/e272132de7ada85bd9b10f0dec2d0c01ea252553))

# [1.5.0](https://github.com/afewell/ovathetap/compare/v1.4.0...v1.5.0) (2022-12-16)


### Features

* Refactor taphostprep-1.sh to support multi-step workflows to resolve [#9](https://github.com/afewell/ovathetap/issues/9) ([fc151f6](https://github.com/afewell/ovathetap/commit/fc151f6d9cda7f41809b0a0976138b6c449e23b5))

# [1.4.0](https://github.com/afewell/ovathetap/compare/v1.3.1...v1.4.0) (2022-12-16)


### Features

* update repo directory naming to better support multi-step workflows to fix [#8](https://github.com/afewell/ovathetap/issues/8) ([ca29288](https://github.com/afewell/ovathetap/commit/ca29288d4002598dd9bbdf35b2b4be9a6d0ccd33))
* update repo directory naming to better support multi-step workflows to fix [#8](https://github.com/afewell/ovathetap/issues/8) ([f17c2d0](https://github.com/afewell/ovathetap/commit/f17c2d02102710645bf5fc7877ec7c71c14c0d75))

## [1.3.1](https://github.com/afewell/ovathetap/compare/v1.3.0...v1.3.1) (2022-12-15)


### Bug Fixes

* removing redundant tap values file from assets to fix [#7](https://github.com/afewell/ovathetap/issues/7) ([8ca895f](https://github.com/afewell/ovathetap/commit/8ca895f0c4040016c5451a1a79e8268a89fddc60))

# [1.3.0](https://github.com/afewell/ovathetap/compare/v1.2.1...v1.3.0) (2022-12-15)


### Features

* adding multiple unpushed updates from test 6 to reach clean slate ([5b6fcd3](https://github.com/afewell/ovathetap/commit/5b6fcd32dd1047ed289402b6a1253826710a1f3d))
* adding multiple unpushed updates from test 6 to reach clean slate ([ebe65fc](https://github.com/afewell/ovathetap/commit/ebe65fc2fbab27085677f435bc057cc9283d249e))

## [1.2.1](https://github.com/afewell/ovathetap/compare/v1.2.0...v1.2.1) (2022-10-29)


### Bug Fixes

* changing files referencing taphostprep repo to ovathetap repo and from devhost.sh to hostprep.sh fixes [#2](https://github.com/afewell/ovathetap/issues/2) ([068990d](https://github.com/afewell/ovathetap/commit/068990d78c4049928c24361913998738135b87f5))

# [1.2.0](https://github.com/afewell/ovathetap/compare/v1.1.1...v1.2.0) (2022-10-18)


### Features

* initial prototype scripts were pushed in the previous (1.1.1) release ([d6f19a0](https://github.com/afewell/ovathetap/commit/d6f19a098b5b4bb3493ec6976c466148cd6c57aa))

## [1.1.1](https://github.com/afewell/ovathetap/compare/v1.1.0...v1.1.1) (2022-10-18)


### Bug Fixes

* deleted artifacts used for testing semantic versioning ([54f51fb](https://github.com/afewell/ovathetap/commit/54f51fb22624738789ff3ccd305a8af3e54c701f))

# [1.1.0](https://github.com/afewell/ovathetap/compare/v1.0.2...v1.1.0) (2022-10-18)


### Features

* Adding /test3.txt to verify semantic release action for features ([ed2d4eb](https://github.com/afewell/ovathetap/commit/ed2d4eb722a6232e12d2d8a431aeace8a0928de2))

## [1.0.2](https://github.com/afewell/ovathetap/compare/v1.0.1...v1.0.2) (2022-10-18)


### Bug Fixes

* Adding /test3.txt to verify semantic release action for features ([82c0a9b](https://github.com/afewell/ovathetap/commit/82c0a9b5e2cf8ceee3962cd9f5e84327e909f35d))

## [1.0.1](https://github.com/afewell/ovathetap/compare/v1.0.0...v1.0.1) (2022-10-18)


### Bug Fixes

* Adding /test3.txt to verify semantic release action for fixes ([fb59cbe](https://github.com/afewell/ovathetap/commit/fb59cbe7ee404b26c3c3bd965576bc6c0a0c4661))

# 1.0.0 (2022-10-17)


### Bug Fixes

* Adding /test2.txt to verify semantic release action ([8d0e059](https://github.com/afewell/ovathetap/commit/8d0e0597a3e6ffe9b9b54f41c1e2218c40ce62c5))
