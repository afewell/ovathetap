# Semantic Versioning Changelog

## [1.13.1](https://github.com/afewell/ovathetap/compare/v1.13.0...v1.13.1) (2022-12-23)


### Bug Fixes

* update certificateauthority.sh to match process defined in harbor 2.6 docs to resolve [#56](https://github.com/afewell/ovathetap/issues/56) ([3ed0e61](https://github.com/afewell/ovathetap/commit/3ed0e6171ec5519e38781a0612d5b2cdf2ede317))

# [1.13.0](https://github.com/afewell/ovathetap/compare/v1.12.1...v1.13.0) (2022-12-23)


### Features

* add a feature commit to demonstrate solution to resolve [#55](https://github.com/afewell/ovathetap/issues/55) ([67a2710](https://github.com/afewell/ovathetap/commit/67a27109a3ebd543255978822359ccd891c7845d))

## [1.12.1](https://github.com/afewell/ovathetap/compare/v1.12.0...v1.12.1) (2022-12-22)


### Bug Fixes

* refactor taphostprep-1 to remove extensive redundancy to resolve [#53](https://github.com/afewell/ovathetap/issues/53) and resolve [#54](https://github.com/afewell/ovathetap/issues/54) ([eb02ca1](https://github.com/afewell/ovathetap/commit/eb02ca15056e979a667991a8920fcdf0bbec57e1))

# [1.12.0](https://github.com/afewell/ovathetap/compare/v1.11.2...v1.12.0) (2022-12-21)


### Features

* move taphostprep-5 to guided execution and update any references and instructions to resolve [#49](https://github.com/afewell/ovathetap/issues/49) and resolve [#48](https://github.com/afewell/ovathetap/issues/48) and resolve [#50](https://github.com/afewell/ovathetap/issues/50) and resolve [#51](https://github.com/afewell/ovathetap/issues/51) ([6474268](https://github.com/afewell/ovathetap/commit/6474268cbd219d2b34254e9452c7f85af7bc6e8b))

## [1.11.2](https://github.com/afewell/ovathetap/compare/v1.11.1...v1.11.2) (2022-12-21)


### Bug Fixes

* move taphostprep-4 to guided execution and update instructions and references to resolve [#47](https://github.com/afewell/ovathetap/issues/47) ([8caaa73](https://github.com/afewell/ovathetap/commit/8caaa73ab282cadd9cf4b0441dded1d7b53ec098))

## [1.11.1](https://github.com/afewell/ovathetap/compare/v1.11.0...v1.11.1) (2022-12-21)


### Bug Fixes

* move taphostprep-3 from script to guided execution, update instructions and references to resolve [#46](https://github.com/afewell/ovathetap/issues/46) and to resolve [#37](https://github.com/afewell/ovathetap/issues/37) ([f73e9d0](https://github.com/afewell/ovathetap/commit/f73e9d04c8c3ded71e3da4244df77ab24c144370))

# [1.11.0](https://github.com/afewell/ovathetap/compare/v1.10.0...v1.11.0) (2022-12-21)


### Features

* relocate content and remove taphost-2.sh and replace references and instructions to resolve [#42](https://github.com/afewell/ovathetap/issues/42) ([d94df41](https://github.com/afewell/ovathetap/commit/d94df41ff198c08b8556d51eedb3da1fa3cfc42d))
* relocate content and remove taphost-2.sh and replace references and instructions to resolve [#42](https://github.com/afewell/ovathetap/issues/42) ([6764b1b](https://github.com/afewell/ovathetap/commit/6764b1bf658101fd24039754e1533a6209e5b70b))

# [1.10.0](https://github.com/afewell/ovathetap/compare/v1.9.8...v1.10.0) (2022-12-21)


### Features

* relocate content and remove taphost-2.sh and replace references and instructions [#42](https://github.com/afewell/ovathetap/issues/42) ([5686ca6](https://github.com/afewell/ovathetap/commit/5686ca626895b88d86c4dd536406cf36be94bafd))

## [1.9.8](https://github.com/afewell/ovathetap/compare/v1.9.7...v1.9.8) (2022-12-20)


### Bug Fixes

* error in dnsmasq config, result is /etc/resolv.conf entries are all squished on one line and one is missing nameserver statement[#41](https://github.com/afewell/ovathetap/issues/41) ([c108354](https://github.com/afewell/ovathetap/commit/c1083547353292d3f6fc8c7cbb9629dff8e59afe))

## [1.9.7](https://github.com/afewell/ovathetap/compare/v1.9.6...v1.9.7) (2022-12-20)


### Bug Fixes

* add instruction for user to export hostusername=<host user name> manually before executing taphostprep-1 scripts[#40](https://github.com/afewell/ovathetap/issues/40) ([da1b0ca](https://github.com/afewell/ovathetap/commit/da1b0ca88609dbdc0e332511a87e31223206e4bf))

## [1.9.6](https://github.com/afewell/ovathetap/compare/v1.9.5...v1.9.6) (2022-12-20)


### Bug Fixes

* change the vars-1.env.sh to vars-1.env.sh.template and prep files [#31](https://github.com/afewell/ovathetap/issues/31) ([315a909](https://github.com/afewell/ovathetap/commit/315a90993fa6b699128eb5ff08e9115fe4c97024))

## [1.9.5](https://github.com/afewell/ovathetap/compare/v1.9.4...v1.9.5) (2022-12-20)


### Bug Fixes

* docker install still causing taphostprep-1.sh to exit prematurely [#39](https://github.com/afewell/ovathetap/issues/39) ([5e611bd](https://github.com/afewell/ovathetap/commit/5e611bd19cf53163201fa10a07ee1ebabb97eb89))

## [1.9.4](https://github.com/afewell/ovathetap/compare/v1.9.3...v1.9.4) (2022-12-19)


### Bug Fixes

* fixing typo in file causing bug ([b68a2b8](https://github.com/afewell/ovathetap/commit/b68a2b8c44ccef664a82d7306b33adb3306f1f9a))

## [1.9.3](https://github.com/afewell/ovathetap/compare/v1.9.2...v1.9.3) (2022-12-19)


### Bug Fixes

* adding leading slash to mkdir "/${script_tmp_dir}" statement in each taphostprep-#.sh file to fix ([465456f](https://github.com/afewell/ovathetap/commit/465456ff79cd9b3135ff6911bea44190c374c398))

## [1.9.2](https://github.com/afewell/ovathetap/compare/v1.9.1...v1.9.2) (2022-12-19)


### Bug Fixes

* adding function definitions to taphostprep-1.sh as problem workaround ([d80431d](https://github.com/afewell/ovathetap/commit/d80431d6ad9958dd234e19dbe9e8a9dc84a3c849))

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
