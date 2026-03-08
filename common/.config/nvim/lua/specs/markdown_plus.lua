local date_format = "%Y.%m.%d - %A"

---@type LazyPluginSpec
return {
    "yousefhadder/markdown-plus.nvim",
    ft = "markdown",
    opts = {
        keymaps = {
            -- Header operations
            promote_header = "<localleader>h+", -- Promote (increase level)
            demote_header = "<localleader>h-", -- Demote (decrease level)
            toggle_heading_style = "<localleader>ms", -- Toggle ATX <-> setext
            generate_toc = "<localleader>ht", -- Generate TOC
            update_toc = "<localleader>hu", -- Update TOC
            open_toc_window = "<localleader>hT", -- Toggle TOC window
            next_header = "]]", -- Jump to next header
            prev_header = "[[", -- Jump to previous header
            set_h1 = "<localleader>h1", -- Convert to H1
            set_h2 = "<localleader>h2", -- Convert to H2
            set_h3 = "<localleader>h3", -- Convert to H3
            set_h4 = "<localleader>h4", -- Convert to H4
            set_h5 = "<localleader>h5", -- Convert to H5
            set_h6 = "<localleader>h6", -- Convert to H6

            -- List operations (Insert mode)
            auto_continue = "<CR>", -- Auto-continue lists or split content
            continue_content = "<A-CR>", -- Continue content on next line
            indent_list = "<C-t>", -- Indent list item
            dedent_list = "<C-d>", -- Dedent list item
            smart_backspace = "<BS>", -- Smart backspace

            -- List operations (Normal mode)
            new_item_below = "o", -- New list item below
            new_item_above = "O", -- New list item above
            renumber_lists = "<localleader>mr", -- Manual renumber
            toggle_checkbox = "<localleader>mx", -- Toggle checkbox (normal/visual)
            debug_lists = "<localleader>md", -- Debug: show list groups

            -- List operations (Insert mode - checkbox)
            toggle_checkbox_insert = "<C-CR>", -- Toggle checkbox in insert mode

            -- Formatting operations (normal + visual)
            toggle_bold = "<localleader>mb",
            toggle_italic = "<localleader>mi",
            toggle_strikethrough = "<localleader>mS",
            toggle_code = "<localleader>m`",
            toggle_highlight = "<localleader>m=",
            toggle_underline = "<localleader>mu",
            escape_selection = "<localleader>me", -- Escape/unescape selection (visual)
            convert_to_code_block = "<localleader>mw", -- Convert selection to code block
            clear_formatting = "<localleader>mF",

            -- Code block operations
            code_block_insert = "<localleader>mc", -- Insert/wrap fenced code block
            code_block_next = "]b", -- Next code block
            code_block_prev = "[b", -- Previous code block
            code_block_change_language = "<localleader>mC", -- Change code block language

            -- Thematic breaks
            insert_thematic_break = "<localleader>mh", -- Insert horizontal rule below cursor
            cycle_thematic_break = "<localleader>mH", -- Cycle --- / *** / ___

            -- Link operations
            insert_link = "<localleader>ml", -- Insert/convert to link
            edit_link = "<localleader>me", -- Edit link under cursor
            auto_link_url = "<localleader>ma", -- Convert URL to link
            to_reference = "<localleader>mR", -- Convert to reference-style
            to_inline = "<localleader>mI", -- Convert to inline
            smart_paste = "<localleader>mp", -- Smart paste URL from clipboard
            follow_link = "gd", -- Follow TOC link
            open_link = "gx", -- Open link in browser (native)

            -- Image operations
            insert_image = "<localleader>mL", -- Insert/convert to image
            edit_image = "<localleader>mE", -- Edit image under cursor
            toggle_image_link = "<localleader>mA", -- Toggle link/image

            -- Quotes operations
            toggle_quote = "<localleader>mq", -- Toggle blockquote

            -- Table operations (Normal mode)
            table_create = "<localleader>tc", -- Create table interactively
            table_format = "<localleader>tf", -- Format table
            table_normalize = "<localleader>tn", -- Normalize malformed table
            table_insert_row_below = "<localleader>tir", -- Insert row below
            table_insert_row_above = "<localleader>tiR", -- Insert row above
            table_delete_row = "<localleader>tdr", -- Delete current row
            table_duplicate_row = "<localleader>tyr", -- Duplicate current row
            table_insert_column_right = "<localleader>tic", -- Insert column right
            table_insert_column_left = "<localleader>tiC", -- Insert column left
            table_delete_column = "<localleader>tdc", -- Delete current column
            table_duplicate_column = "<localleader>tyc", -- Duplicate current column
            table_toggle_alignment = "<localleader>ta", -- Toggle cell alignment
            table_clear_cell = "<localleader>tx", -- Clear cell content
            table_move_column_left = "<localleader>tmh", -- Move column left
            table_move_column_right = "<localleader>tml", -- Move column right
            table_move_row_up = "<localleader>tmk", -- Move row up
            table_move_row_down = "<localleader>tmj", -- Move row down
            table_transpose = "<localleader>tt", -- Transpose table
            table_sort_ascending = "<localleader>tsa", -- Sort by column (ascending)
            table_sort_descending = "<localleader>tsd", -- Sort by column (descending)
            table_to_csv = "<localleader>tvx", -- Convert table to CSV
            csv_to_table = "<localleader>tvi", -- Convert CSV to table

            -- Table operations (Insert mode)
            table_move_left = "<A-h>", -- Move to cell left (wraps)
            table_move_right = "<A-l>", -- Move to cell right (wraps)
            table_move_down = "<A-j>", -- Move to cell down (wraps)
            table_move_up = "<A-k>", -- Move to cell up (wraps)

            -- Footnotes operations (Normal mode)
            footnote_insert = "<localleader>mfi", -- Insert new footnote
            footnote_edit = "<localleader>mfe", -- Edit footnote definition
            footnote_delete = "<localleader>mfd", -- Delete footnote
            footnote_goto_definition = "<localleader>mfg", -- Go to footnote definition
            footnote_goto_reference = "<localleader>mfr", -- Go to footnote reference(s)
            footnote_next = "<localleader>mfn", -- Next footnote
            footnote_prev = "<localleader>mfp", -- Previous footnote
            footnote_list = "<localleader>mfl", -- List all footnotes
        },
        list = {
            smart_outdent = true,
            checkbox_completion = {
                enabled = false,
                format = "emoji", -- "emoji" | "comment" | "dataview" | "parenthetical"
                date_format = date_format,
                remove_on_uncheck = true,
                update_existing = true,
            },
        },
    },
}
