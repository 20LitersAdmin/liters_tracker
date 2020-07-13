# CURRENT:
0. Geographies now have visible / hidden scopes
==
- Views (*all* need work)
-- cell#show has `hierarchy_with_links`
-- edit / back buttons should be `class: small` on show views
-- Add `hidden.html.haml` "index" views for all but Facility

- Policies (all need hidden? except Facility)

- Forms (need check_box for hidden)

- Hidden indexes need DataTables:
- Sectors
- Cells
- Villages

- Controllers:
-- Add make_visible to `before_action :set_record`
-- Flash messages on `show` when `@record.hidden?`
-- Update record_params to include hidden
-- Add `def hidden; end` action

0. Dashboard
- basic_stat_blocks aren't collapsing like they used to?

0. New model tests in geographies (Report and Plan want to be able to call any geography)

0. Sector#report forms have better geography error handling in views than Plans, Facilities forms. See `report_error.js.erb`

1. Contracts/Plans architecture:
- Plans#edit form will need some work in controller for geographies, right?

2. What about un-met plans?
- Help Rebero see work to be accomplished by Sector

3. Deleting a (duplicate) Facility that has associated Reports:
- Need to re-assign reports before deleting facility
- or create a Merge function?

# Forms
- Tech form

# Geography forms (also need a chooser view)
- Country form
- District form
- Sector form
- Cell form
- Village form

# Indexes need:
- Facilities: datatables (replace will_paginate)

# Shows need:
- Facility: reports / plans

# Remind myself:
* `magic_frozen_string_literal . #get those frozen string benefits`
* production backup / development restore-from production (https://github.com/thoughtbot/parity)
  `User.first.reset_password('password', 'password')`
* byebug commands
    continue   -- Runs on
    delete     -- Deletes breakpoints
    finish     -- Runs the program until frame returns
    irb        -- Starts an IRB session
    kill       -- Sends a signal to the current process
    quit       -- Exits byebug
    restart    -- Restarts the debugged program
