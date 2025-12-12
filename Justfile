doc:
    vimcats -t -f -c -a \
    lua/warp/init.lua \
    lua/warp/config.lua \
    lua/warp/list.lua \
    lua/warp/storage.lua \
    lua/warp/ui.lua \
    lua/warp/utils.lua \
    lua/warp/notifier.lua \
    lua/warp/builtins.lua \
    lua/warp/events.lua \
    lua/warp/types.lua \
    > doc/warp.nvim.txt

set shell := ["bash", "-cu"]

fmt-check:
    stylua --config-path=.stylua.toml --check lua

fmt:
    stylua --config-path=.stylua.toml lua

lint:
    @if lua-language-server --configpath=.luarc.json --check=. --check_format=pretty --checklevel=Warning 2>&1 | grep -E 'Warning|Error'; then \
        echo "LSP lint failed"; \
        exit 1; \
    else \
        echo "LSP lint passed"; \
    fi

test:
    @echo "Running tests in headless Neovim using test_init.lua..."
    nvim -l tests/minit.lua --minitest
