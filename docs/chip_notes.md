# BUGS:
- sectors/reports: ditch complex JS to manage reportable_id and reportable_type; now use the controller to determine reportable
  - needs to work for _village_form and _facility_form
  - also affects plan creation (contracts_plan.coffee)
- finders.coffee has a bunch of useless JS now:
  - removed: @assessPolymorphics
  - @forcePolymorphics & child methods
  - @clearPolymorphics & child methods

# PLANS:
- Community Tech plans MUST be associated with a Facility, but shouldn't have to be?
- Family Tech plans MUST be associated with a Village (but maybe could be generalized to a cell?)
- Engagement Tech plans: Form says "Goal", should say "Hours"?, or add Plan#hours to db?

# NEXT:
0. Code smells: All geographies respond to all geographies
- E.g. Cell:28-49
- remove method from Country, District, Sector
- deal with PlansController:46-47
- deal with ReportsController:41
-

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
** General model format**
 - CURRENTLY MISSING: destroy: always from edit page? Add to model_form_spec?
 - model_form_spec: new/create/edit/update
 - model_index_spec: index
 - model_show_spec: show

- managing targets

- viewing data
-- data page
-- data_filter page
-- stats page
-- monthly page
-- monthly show page (:year/:month)

- managing reports

- managing stories
-- form functions
-- adding a photo
-- editing a photo
-- removing a photo

- user confirmation email


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
