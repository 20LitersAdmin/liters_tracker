# CURRENT:

0. DEBATE: Training reports:
- 'One person is trained multiple times, so what stat and language matters?'
- Count value in :distributed vs :people?
- Show on dashboard?
- "in the month of January, X people were trained Y times"
- Volunteers as a "Community" scope?
- Training Tech has impact of 0
- Does Technology need more booleans:
-- :is_training? - replace @technology.name.includes?('Train')
-- :dashboard_worthy? - replace @technology.report_worthy? in DashboardController


0. sectors/:id/report
- When technology is Training, include a message about how to complete [Distributed][People][Checked]

1. What about un-met plans?
- Help Rebero see work to be accomplished by Sector


2. Deleting a (duplicate) Facility that has associated Reports:
- Need to re-assign reports before deleting facility

3. technology_path(:id)
- Add Report button does nothing
- Add Plan button does nothing

# Creating/Updating Targets

# Creating/Updating Plans
* Copy the sector/select && sector/#id/report process

# Forms
- Tech form
- Contract form
- Target form
- Plan form

# Geography forms (also need a chooser view)
- Country form
- District form
- Sector form
- Cell form
- Village form

# Indexes need:
- Facilities: datatables (replace will_paginate)
- Reports: datatables (replace will_paginate)
- all geographies: datatables (replace will_paginate)

# Shows need:
- Facility: reports / plans

# Remind myself:
* `magic_frozen_string_literal . #get those frozen string benefits`
* production backup / development restore-from production (https://github.com/thoughtbot/parity)
  `User.first.update(password: 'password', password_confirmation: 'password')`
* byebug commands
    continue   -- Runs on
    delete     -- Deletes breakpoints
    finish     -- Runs the program until frame returns
    irb        -- Starts an IRB session
    kill       -- Sends a signal to the current process
    quit       -- Exits byebug
    restart    -- Restarts the debugged program
