# CURRENT:
0. Contracts/:id/plan is ready to test form submission to Plans#create

# NEXT:
0. Contract/:id/plan should show existing plans by sector


0. Plans#new.html is dead, right?

0. SectorsReport.coffee: shouldn't need setPolymorphic or selectLogic, handled by finders.coffee. Try removing and see what happens.

0. Monthly report: Community Engagement reports:
- Says: [ Sector  Cell  Village Distributed Checked People served ]
- Should say: [ Sector  Cell  Village People Hours Impact ]

Sandardize: Show views
- edit / back buttons should be `class: small` on show views

- Forms (need check_box for hidden)

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

# Geography index views: I removed total rows for speed
- If we want totals: https://datatables.net/examples/advanced_init/footer_callback.html

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
