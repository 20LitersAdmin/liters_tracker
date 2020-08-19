# PLANS:
- Community Tech plans MUST be associated with a Facility, but shouldn't have to be?
- Family Tech plans MUST be associated with a Village (but maybe could be generalized to a cell?)
- Engagement Tech plans: Form says "Goal", should say "Hours"?, or add Plan#hours to db?

# NEXT:
0. Facilities#index needs dttb ajax instead of paginate / like Reports#dttb_index

0. Forms could have geography selects (with Global Linked Selects)
- Reports#edit
- Plans#edit

0. Monthly report: Community Engagement reports:
- Says: [ Sector  Cell  Village Distributed Checked People served ]
- Should say: [ Sector  Cell  Village People Hours Impact ]

Sandardize: Show views
- edit / back buttons should be `class: small` on show views
- Forms (need check_box for hidden)

0. Sector#report forms have better geography error handling in views than Plans, Facilities forms. See `report_error.js.erb`

2. What about un-met plans?
- Help Rebero see work to be accomplished by Sector

# System specs:
- logout
- managing users

- viewing data
-- data page
-- data_filter page
-- stats page
-- monthly page
-- monthly show page (:year/:month)

- managing reports
- managing stories
-- creating a story
-- adding a photo
-- editing a photo
-- removing a photo

- managing facilities

- managing technologies

- managing contracts
- managing plans
- managing targets


# OVERALL CUSTOM REPORTS VIEW:
- Use Cornerstone Trust grant report as a sample
- Choose time period (or all-time)
- Choose technologies (multi-select)
- Choose locations (multi-select Districts or Sectors?) (really flexible, selecting children automatically)

# Geography index views: I removed total rows for speed
- If we want totals: https://datatables.net/examples/advanced_init/footer_callback.html
- Could simplify to CRUD with overall reports view

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
