return {
    {
        "coder/claudecode.nvim",
        dev = false,
        opts = {

            terminal = {
                provider = "none",
            },
        },
        config = function(_, opts)
            require("claudecode").setup(opts)
        end,
    },
    {
        name = "run-ai.run",
        dir = "/home/yuv/proj/run-ai.run.nvim",
        enabled = false,
        cmd = { "LlmReplace" },
        dependencies = {
            "3dyuval/colortweak.nvim",
            "nvim-lua/plenary.nvim",
            "folke/noice.nvim",
            "olimorris/codecompanion.nvim"
        },
        opts = {
            skills_path = "/home/yuv/.config/nvim/.claude/skills",
            log_level = "debug",
            notify_level = "warn", -- nil = off, "debug"/"info"/"warn"/"error" = show in noice
            highlights = {
                normal = "ClaudeNormal",
                thinking = "ClaudeThinking",
            },
        },
        config = function(_, opts)
            local tweak = require("colortweak.tweak")

            tweak.hl({
                ClaudeNormal = { "DiagnosticInfo", { h = -5, s = 1 } },
                ClaudeThinking = { "DiagnosticHint", { h = 15, s = 1.5 } },
            })

            opts.providers = {
                {
                    name = "theyuval",
                    base_url = "https://api.theyuval.com/ai/v1",
                    model_prefixes = { "theyuval/" },
                    auth_header = "Bearer",
                },
            }

            opts.liter = {
                api_key = os.getenv("API_KEY"),
                model = "theyuval/qwen3.5-9b:instruct",
            }

            require("run-ai-run").setup(opts)
        end,
    },
    {
        enabled = false,
        dir = "/home/yuv/proj/test",
        name = "interview-timer",
        lazy = false,
        dependencies = { "ravsii/timers.nvim" },
        config = function()
            require("timers").setup({})
            require("interview-timer").setup({
                ["time-limit-min"] = 20,
                provider = "claude-acp",
                ["acp-providers"] = {
                    ["claude-acp"] = {
                        command = "/home/yuv/.nvm/versions/node/v20.19.6/bin/claude-code-acp",
                    },
                },
            })
        end,
    },
    {
        "yetone/avante.nvim",
        enabled = false,
        version = false,
        build = "make",
        event = "VeryLazy",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "stevearc/dressing.nvim",
            "nvim-tree/nvim-web-devicons",
            "MeanderingProgrammer/render-markdown.nvim",
        },
        opts = {
            provider = "opencode",
            mode = "agentic",
            behaviour = {
                auto_set_highlight_group = true,
                auto_set_keymaps = true,
                auto_apply_diff_after_generation = false,
                minimize_diff = true,
                enable_token_counting = true,
                auto_add_current_file = true,
                auto_approve_tool_permissions = true,
            },
            acp_providers = {
                ["opencode"] = {
                    command = "opencode",
                    args = { "acp" },
                    env = {
                        API_KEY = os.getenv("API_KEY"),
                        TAVILY_API_KEY = os.getenv("TAVILY_API_KEY"),
                    },
                },
                ["claude-code"] = {
                    command = "npx",
                    args = { "@zed-industries/claude-code-acp" },
                    env = {
                        NODE_NO_WARNINGS = "1",
                        ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY"),
                    },
                },
            },
            web_search_engine = {
                provider = "tavily",
                proxy = nil,
                api_key_name = "TAVILY_API_KEY",
            },
            windows = {
                position = "right",
                wrap = true,
                width = 30,
            },
            input = {
                provider = "snacks",
            },
            selector = {
                provider = "snacks",
            },
        },
    },
}
