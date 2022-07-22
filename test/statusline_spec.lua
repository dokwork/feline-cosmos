local Statusline = require('compline.statusline')

describe('Building componentns', function()
    it('should build components and sections in correct order', function()
        -- given:
        local statusline = Statusline.new('test', {
            active = {
                left = {
                    b = { 'b', 'c' },
                    a = { 'a' },
                },
            },
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    { provider = 'a' },
                    { provider = 'b' },
                    { provider = 'c' },
                },
                {},
                {},
            },
        }
        local msg = string.format(
            '\nExpected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)

    it('should resolve components by their names', function()
        -- given:
        local components = {
            some_component = { provider = 'example' },
        }
        local statusline = Statusline.new('test', {
            active = {
                left = {
                    a = { 'some_component' },
                },
            },
            components = components,
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    { provider = 'example' },
                },
                {},
                {},
            },
        }
        local msg = string.format(
            '\nExpected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)

    it('should add hl to components from the theme', function()
        -- given:
        local components = {
            some_component = { provider = 'example' },
        }
        local theme = {
            active = {
                left = {
                    sections = {
                        a = { hl = { fg = 'black', bg = 'whignoree' } },
                    },
                },
            },
        }
        local statusline = Statusline.new('test', {
            active = {
                left = {
                    a = { 'some_component' },
                },
            },
            components = components,
            themes = {
                default = theme,
            },
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    { provider = 'example', hl = { fg = 'black', bg = 'whignoree' } },
                },
                {},
                {},
            },
        }
        local msg = string.format(
            '\nExpected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)

    it("should use hl from a component when ignore's specified", function()
        -- given:
        local components = {
            some_component = { provider = 'example', hl = { fg = 'red' } },
        }
        local theme = {
            active = {
                left = {
                    sections = {
                        a = { hl = { fg = 'black', bg = 'whignoree' } },
                    },
                },
            },
        }
        local statusline = Statusline.new('test', {
            active = {
                left = {
                    a = { 'some_component' },
                },
            },
            components = components,
            themes = {
                default = theme,
            },
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    { provider = 'example', hl = { fg = 'red' } },
                },
                {},
                {},
            },
        }
        local msg = string.format(
            '\nExpected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)

    it("should create components for zone's separators", function()
        -- given:
        local theme = {
            active = {
                left = {
                    separators = { left = '<', right = { '>', hl = { fg = 'red' } } },
                },
            },
        }
        local statusline = Statusline.new('test', {
            active = { left = { a = { 'test' } } },
            themes = {
                default = theme,
            },
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    { provider = '<' },
                    { provider = 'test' },
                    { provider = '>', hl = { fg = 'red' } },
                },
                {},
                {},
            },
        }
        local msg = string.format(
            '\nExpected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)

    it("should add section's separators to the first and last components", function()
        -- given:
        local theme = {
            active = {
                left = {
                    sections = {
                        separators = { left = '<', right = { '>', hl = { fg = 'red' } } },
                    },
                },
            },
        }
        local statusline = Statusline.new('test', {
            active = { left = { a = { 'test' } } },
            themes = {
                default = theme,
            },
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    {
                        provider = 'test',
                        left_sep = '<',
                        right_sep = { str = '>', hl = { fg = 'red' } },
                    },
                },
                {},
                {},
            },
        }
        local msg = string.format(
            '\nExpected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)

    it("zone's separators must override sections separators", function()
        -- given:
        local theme = {
            active = {
                left = {
                    separators = { left = ' ', right = ' ' },
                    sections = {
                        separators = { left = '<', right = '>' },
                    },
                },
            },
        }
        local statusline = Statusline.new('test', {
            active = {
                left = {
                    a = { 'test 1' },
                    b = { 'test 2' },
                },
            },
            themes = {
                default = theme,
            },
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    { provider = ' ' },
                    { provider = 'test 1', right_sep = '>' },
                    { provider = 'test 2', left_sep = '<' },
                    { provider = ' ' },
                },
                {},
                {},
            },
        }
        local msg = string.format(
            '\nExpected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)

    it('should add separators to the components', function()
        -- given:
        local theme = {
            active = {
                left = {
                    sections = {
                        a = {
                            separators = { left = { '<' }, right = { '>', hl = { fg = 'red' } } },
                        },
                    },
                },
            },
        }
        local statusline = Statusline.new('test', {
            themes = {
                default = theme,
            },
            active = {
                left = {
                    a = { 'test' },
                },
            },
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    {
                        provider = 'test',
                        left_sep = { str = '<' },
                        right_sep = { str = '>', hl = { fg = 'red' } },
                    },
                },
                {},
                {},
            },
        }
        local msg = string.format(
            '\nExpected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)

    it("section's separators must override component's separators", function()
        -- given:
        local theme = {
            active = {
                left = {
                    sections = {
                        separators = { left = ' ', right = ' ' },
                        a = { separators = { left = '<', right = '>' } },
                    },
                },
            },
        }
        local statusline = Statusline.new('test', {
            themes = {
                default = theme,
            },
            active = {
                left = {
                    a = { 'test1', 'test2' },
                },
            },
        })

        -- when:
        local result = statusline:build_components()

        -- then:
        local expected = {
            active = {
                {
                    {
                        provider = 'test1',
                        left_sep = ' ',
                        right_sep = '>',
                    },
                    {
                        provider = 'test2',
                        left_sep = '<',
                        right_sep = ' ',
                    },
                },
                {},
                {},
            },
        }
        local msg = string.format(
            '\nExpected:\n%s\nActual:\n%s',
            vim.inspect(expected),
            vim.inspect(result)
        )
        assert.are.same(expected, result, msg)
    end)
end)
