# Changelog

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
