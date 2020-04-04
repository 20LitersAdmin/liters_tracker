# CURRENT:
0. ISSUES:
- narrative report showing Slow Sand and track showing SAM3 [May 2018] or two SAM2 in track for April 2018 that aren't mentioned in any narrative reports in the quarter

1. Plans architecture:
- Plan form
-- geography: contracts/{:id}/plans
-- technology: technologies/{:id}/plans

2. What about un-met plans?
- Help Rebero see work to be accomplished by Sector

3. Deleting a (duplicate) Facility that has associated Reports:
- Need to re-assign reports before deleting facility
- or create a Merge function?

4. technology_path(:id)
- Add Plan button does nothing

# Creating/Updating Targets

# Creating/Updating Plans
* Copy the sector/select && sector/#id/report process

# Forms
- Contract form
- Tech form
- Target form


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
