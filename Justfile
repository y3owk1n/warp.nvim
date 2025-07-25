doc:
    vimcats -t -f -c -a \
    lua/warp/init.lua \
    lua/warp/config.lua \
    lua/warp/list.lua \
    lua/warp/storage.lua \
    lua/warp/ui.lua \
    lua/warp/utils.lua \
    lua/warp/types.lua \
    > doc/warp.nvim.txt

set shell := ["bash", "-cu"]

test:
    @echo "Running tests in headless Neovim using test_init.lua..."
    nvim -l tests/minit.lua --minitest
