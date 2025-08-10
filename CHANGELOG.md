# Changelog

## [1.3.2](https://github.com/y3owk1n/warp.nvim/compare/v1.3.1...v1.3.2) (2025-08-10)


### Bug Fixes

* **ci:** move docs to its own workflow ([#70](https://github.com/y3owk1n/warp.nvim/issues/70)) ([a2d49da](https://github.com/y3owk1n/warp.nvim/commit/a2d49da69e55c3ed18134957e309288c84436775))

## [1.3.1](https://github.com/y3owk1n/warp.nvim/compare/v1.3.0...v1.3.1) (2025-07-29)


### Bug Fixes

* add `show_help` to docs config section ([#58](https://github.com/y3owk1n/warp.nvim/issues/58)) ([0088800](https://github.com/y3owk1n/warp.nvim/commit/008880048beed811dcee2e321b8979447f3e1365))
* add configurable `win_opts` for each `warp` managed windows ([#62](https://github.com/y3owk1n/warp.nvim/issues/62)) ([531594b](https://github.com/y3owk1n/warp.nvim/commit/531594b15e845d88b34de1a0aad18046d5c444dd))
* add help menu & fix window flashes ([#57](https://github.com/y3owk1n/warp.nvim/issues/57)) ([bc64e74](https://github.com/y3owk1n/warp.nvim/commit/bc64e746677e9ba5dede615a1c24f5c121ecbae8))
* ensure `cursor` doesn't jump to 1 after `delete` a line ([#56](https://github.com/y3owk1n/warp.nvim/issues/56)) ([8dcb2b8](https://github.com/y3owk1n/warp.nvim/commit/8dcb2b84c36f734c2d4ccdb683367e3e84b64b71))
* ensure float win_config gets from configurations ([#59](https://github.com/y3owk1n/warp.nvim/issues/59)) ([24222db](https://github.com/y3owk1n/warp.nvim/commit/24222dbd7a9473337a1131e5feaeadd2be3b70f8))
* improve hl detection logic by calculating the `col_start` & `col_end` for each defined items ([#64](https://github.com/y3owk1n/warp.nvim/issues/64)) ([bab8b65](https://github.com/y3owk1n/warp.nvim/commit/bab8b65ba5171d3c91fbf36ab02a336b5d5d5eb9))
* improve UI parsing with virtual text support ([#67](https://github.com/y3owk1n/warp.nvim/issues/67)) ([6b6711c](https://github.com/y3owk1n/warp.nvim/commit/6b6711c16d0ee603202ad4733b213994f5d41105))
* make `list_item_format_fn` more configurable with text & highlights ([#50](https://github.com/y3owk1n/warp.nvim/issues/50)) ([c4c9429](https://github.com/y3owk1n/warp.nvim/commit/c4c9429178e2f43a9537f07bd53619b407f9b9f5))
* make hlgroups customisable ([#69](https://github.com/y3owk1n/warp.nvim/issues/69)) ([ae74331](https://github.com/y3owk1n/warp.nvim/commit/ae74331e51eb58b91cbd1c083690a9b7f130eb66))
* make most naming of variables more concise ([#65](https://github.com/y3owk1n/warp.nvim/issues/65)) ([9822b38](https://github.com/y3owk1n/warp.nvim/commit/9822b380f02955215f8e839397427a80373e43e4))
* make pruning configurable and update list item formatter ([#53](https://github.com/y3owk1n/warp.nvim/issues/53)) ([fc8254a](https://github.com/y3owk1n/warp.nvim/commit/fc8254aa2ba31b37e2ed29c33893a601f87d6e31))
* minimise repeated imports ([#52](https://github.com/y3owk1n/warp.nvim/issues/52)) ([b0fbb5f](https://github.com/y3owk1n/warp.nvim/commit/b0fbb5f81842d71c0c2a3c30356a875edcbc8978))
* remove configurable float_opts ([#60](https://github.com/y3owk1n/warp.nvim/issues/60)) ([cfae79a](https://github.com/y3owk1n/warp.nvim/commit/cfae79ad6db712731b1b5d0007e7b1ccd4a4d479))
* remove Snacks.debug, oppsie ([#63](https://github.com/y3owk1n/warp.nvim/issues/63)) ([6d85fdd](https://github.com/y3owk1n/warp.nvim/commit/6d85fdd37b6ac340fc9d2b7cd793ae1990022ecf))
* set cursorline to `vim.o.cursorline` ([#61](https://github.com/y3owk1n/warp.nvim/issues/61)) ([7a20870](https://github.com/y3owk1n/warp.nvim/commit/7a20870e587418fa32c94c47dfd7df2266ab0abc))
* show `cursorline` in float ([#55](https://github.com/y3owk1n/warp.nvim/issues/55)) ([c9060f5](https://github.com/y3owk1n/warp.nvim/commit/c9060f59b5796c7936187dcb1c7f99e7858ea2dc))
* update docs & types typo ([#68](https://github.com/y3owk1n/warp.nvim/issues/68)) ([1556818](https://github.com/y3owk1n/warp.nvim/commit/155681806f7b9e71d0ac9ff53cc6fcfbaf5a1619))

## [1.3.0](https://github.com/y3owk1n/warp.nvim/compare/v1.2.0...v1.3.0) (2025-07-26)


### Features

* add `add_all_onscreen` API ([#44](https://github.com/y3owk1n/warp.nvim/issues/44)) ([c75b7be](https://github.com/y3owk1n/warp.nvim/commit/c75b7bebb3700c815479246b27f74aff4378d996))


### Bug Fixes

* add `VimLeavePre` for cursor updating autocmd ([#48](https://github.com/y3owk1n/warp.nvim/issues/48)) ([56509ac](https://github.com/y3owk1n/warp.nvim/commit/56509ac2a10d9dc06668e107ba755cbec9b2dd92))
* do not add if it's not an existing path ([#47](https://github.com/y3owk1n/warp.nvim/issues/47)) ([e112bb7](https://github.com/y3owk1n/warp.nvim/commit/e112bb7eda931bedaf0065d0e89fe7bfd3b05dd5))
* use `vim.uv` instead of `vim.loop` for `fs_stat` ([#46](https://github.com/y3owk1n/warp.nvim/issues/46)) ([de4c529](https://github.com/y3owk1n/warp.nvim/commit/de4c529410d958d52a69e5a2dff72285396baa09))

## [1.2.0](https://github.com/y3owk1n/warp.nvim/compare/v1.1.0...v1.2.0) (2025-07-26)


### Features

* switch from `line_number` to `cursor` position & make it auto update itself ([#40](https://github.com/y3owk1n/warp.nvim/issues/40)) ([f08a9e6](https://github.com/y3owk1n/warp.nvim/commit/f08a9e6d7252da5c359895f36aec8b3c4b7bf316))


### Bug Fixes

* abort `goto` if it's already the index ([#41](https://github.com/y3owk1n/warp.nvim/issues/41)) ([b1ad174](https://github.com/y3owk1n/warp.nvim/commit/b1ad174fcfbd328b524c96ee954a75d0fb78d607))
* add split keymaps to list window ([#39](https://github.com/y3owk1n/warp.nvim/issues/39)) ([3ad425a](https://github.com/y3owk1n/warp.nvim/commit/3ad425a6c9970eadfbe11fd154efe41e0c622996))
* better clear all list logic ([#31](https://github.com/y3owk1n/warp.nvim/issues/31)) ([8086312](https://github.com/y3owk1n/warp.nvim/commit/80863129e2d45d71d750a6208173682fc8ee0534))
* call `redrawstatus` when relevant events happen ([#33](https://github.com/y3owk1n/warp.nvim/issues/33)) ([791417a](https://github.com/y3owk1n/warp.nvim/commit/791417ae39fecc848e8545115e14a688ec51d911))
* typo on `[@usage](https://github.com/usage)` due to refactoring ([#34](https://github.com/y3owk1n/warp.nvim/issues/34)) ([50e3842](https://github.com/y3owk1n/warp.nvim/commit/50e384216c1d5bfc5ce1f6ba54ae883f85af9cf8))
* use defined actions for moving up and down ([#35](https://github.com/y3owk1n/warp.nvim/issues/35)) ([825389c](https://github.com/y3owk1n/warp.nvim/commit/825389cdb6857d1f822153229589438f911e374a))
* wrong `[@see](https://github.com/see)` for `M.count` ([#38](https://github.com/y3owk1n/warp.nvim/issues/38)) ([1a4188c](https://github.com/y3owk1n/warp.nvim/commit/1a4188c3e7e57b12b38adb90177e9d7845b9a41e))

## [1.1.0](https://github.com/y3owk1n/warp.nvim/compare/v1.0.1...v1.1.0) (2025-07-26)


### Features

* add `delete` command ([#26](https://github.com/y3owk1n/warp.nvim/issues/26)) ([aed5713](https://github.com/y3owk1n/warp.nvim/commit/aed5713f1a81b3623dcd3667c29dc7cdbe78d1fa))
* add `moveTo` command ([#27](https://github.com/y3owk1n/warp.nvim/issues/27)) ([b6653c5](https://github.com/y3owk1n/warp.nvim/commit/b6653c510f78610df52d7763e6a2b55f82604118))
* add directions support for `goto` commands ([#28](https://github.com/y3owk1n/warp.nvim/issues/28)) ([9b7f778](https://github.com/y3owk1n/warp.nvim/commit/9b7f77809a127645d329395f371aba02326aebed))


### Bug Fixes

* refactoring names, functions & files ([#24](https://github.com/y3owk1n/warp.nvim/issues/24)) ([3063164](https://github.com/y3owk1n/warp.nvim/commit/306316405b3993b5983d080b1658fce35748e2b3))

## [1.0.1](https://github.com/y3owk1n/warp.nvim/compare/v1.0.0...v1.0.1) (2025-07-25)


### Bug Fixes

* add `pcall` to setting the cursor when `goto_index` ([#15](https://github.com/y3owk1n/warp.nvim/issues/15)) ([16eabd1](https://github.com/y3owk1n/warp.nvim/commit/16eabd173dea7cfb8e1b132af0bda9d3e11c1d56))
* add a space in the UI for better cursor showing ([#10](https://github.com/y3owk1n/warp.nvim/issues/10)) ([102bf83](https://github.com/y3owk1n/warp.nvim/commit/102bf8312650c7f34cf2e869d7c28a6434d5d759))
* add configurable `root_detection` ([#6](https://github.com/y3owk1n/warp.nvim/issues/6)) ([f002e1e](https://github.com/y3owk1n/warp.nvim/commit/f002e1ed2620aeb5275acecfc8fbf7621d16a28a))
* ensure cleanup of all `warp.action` instances ([#9](https://github.com/y3owk1n/warp.nvim/issues/9)) ([aeaf122](https://github.com/y3owk1n/warp.nvim/commit/aeaf122ffd943365bf6aefba8601e82cddb57f58))
* ensure to close the window when deleting the last entry ([#14](https://github.com/y3owk1n/warp.nvim/issues/14)) ([8613e97](https://github.com/y3owk1n/warp.nvim/commit/8613e97380dbb2a50ae7140757987f126d693e5f))
* ensure UI moving items persist the "*" ([#16](https://github.com/y3owk1n/warp.nvim/issues/16)) ([7b8e358](https://github.com/y3owk1n/warp.nvim/commit/7b8e358f62f85084f6cca32daa45ce870da5cdf7))
* events emission implementation ([#23](https://github.com/y3owk1n/warp.nvim/issues/23)) ([d04340b](https://github.com/y3owk1n/warp.nvim/commit/d04340b88807795f9e4ec29db3d31a76a6c05573))
* expose useful APIs in the main module ([#8](https://github.com/y3owk1n/warp.nvim/issues/8)) ([8242c5f](https://github.com/y3owk1n/warp.nvim/commit/8242c5f1dd831c8698baa12993317e91811068ee))
* improve root detection fn selection ([#20](https://github.com/y3owk1n/warp.nvim/issues/20)) ([0cd1a91](https://github.com/y3owk1n/warp.nvim/commit/0cd1a9175c181903f485b1ddd941a90862579e6b))
* make list items format configurable ([#19](https://github.com/y3owk1n/warp.nvim/issues/19)) ([b4fae4e](https://github.com/y3owk1n/warp.nvim/commit/b4fae4e19443e3e715eee70d3b8e0570eb309bbc))
* make UI floats configurable ([#18](https://github.com/y3owk1n/warp.nvim/issues/18)) ([ff263b0](https://github.com/y3owk1n/warp.nvim/commit/ff263b065fac2cb1c86d85a396e7d02290513607))
* move `notifier` into it's own module ([#11](https://github.com/y3owk1n/warp.nvim/issues/11)) ([927a62b](https://github.com/y3owk1n/warp.nvim/commit/927a62b726d59bd2fc6bbc73e3d4e40a8eefa361))
* only save_list if pruned files ([#22](https://github.com/y3owk1n/warp.nvim/issues/22)) ([d7e0540](https://github.com/y3owk1n/warp.nvim/commit/d7e0540955bdbb4f46dbf952cca429e33c7f417b))
* refactor UI codes to be more separated ([#21](https://github.com/y3owk1n/warp.nvim/issues/21)) ([ba8408a](https://github.com/y3owk1n/warp.nvim/commit/ba8408a70c752a0dfa8f06e422315ff1c1eacc21))
* respect `winborder` set from user ([#17](https://github.com/y3owk1n/warp.nvim/issues/17)) ([bec5f04](https://github.com/y3owk1n/warp.nvim/commit/bec5f041dbad30554ccbc4487023fd820574926c))
* slight refactor of root discovery ([#3](https://github.com/y3owk1n/warp.nvim/issues/3)) ([4e45efd](https://github.com/y3owk1n/warp.nvim/commit/4e45efde2879d304de8870cabd3e37c511ed1e84))
* use `:edit` to load buffer so plugins like Heirline detect Git context ([#7](https://github.com/y3owk1n/warp.nvim/issues/7)) ([186af18](https://github.com/y3owk1n/warp.nvim/commit/186af18ebbb5e1851e61ec4afd830dc3da5e135f))

## 1.0.0 (2025-07-24)


### Features

* conversion from config code to plugin ([#1](https://github.com/y3owk1n/warp.nvim/issues/1)) ([d925c90](https://github.com/y3owk1n/warp.nvim/commit/d925c90f49db77d5b3c698ec99f79b488d770a68))
