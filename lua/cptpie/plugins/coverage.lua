return {
  "andythigpen/nvim-coverage",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local coverage = require("coverage")

    coverage.setup({
      auto_reload = true,
      lang = {
        rust = {
          coverage_command = "grcov ${cwd} -s ${cwd} --binary-path ./target/debug/ -t coveralls --branch --ignore-not-existing --token NO_TOKEN --llvm-path /usr/bin",
        },
      },
    })

    local keymap = vim.keymap

    keymap.set("n", "<leader>cl", "<cmd>CoverageLoad<cr>", { desc = "Load coverage data" })
    keymap.set("n", "<leader>ct", "<cmd>CoverageToggle<cr>", { desc = "Toggle coverage gutter signs" })
    keymap.set("n", "<leader>cs", "<cmd>CoverageSummary<cr>", { desc = "Show coverage summary" })

    local coverage_commands = {
      rust = "CARGO_INCREMENTAL=0 RUSTFLAGS='-Cinstrument-coverage' LLVM_PROFILE_FILE='target/coverage/%%p-%%m.profraw' cargo test",
      go = "go test -coverprofile=coverage.out ./...",
      python = "coverage run -m pytest && coverage lcov -o lcov.info",
    }

    keymap.set("n", "<leader>cr", function()
      local ft = vim.bo.filetype
      local cmd = coverage_commands[ft]
      if cmd then
        vim.cmd("!" .. cmd)
      else
        vim.notify("No coverage command configured for filetype: " .. ft, vim.log.levels.WARN)
      end
    end, { desc = "Run tests with coverage instrumentation" })
  end,
}
