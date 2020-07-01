# CURRENT:
0. Load dashboard to a specific year && month

0. Feature specs

0. Geography navigation:
- links to child geograhy are missing date filters
- links to technologies contain no geography or date filters

1. Plans architecture:
- Plan form
-- geography: contracts/{:id}/plans
-- technology: technologies/{:id}/plans

1. Geography views:
- Add Plan button does nothing
- Add Report button does nothing
-- Reports can only be added from `_technology` partials, date is gracefully added if not included
-- Check each level of geography

1. User permissions
- `(current_user.can_manage_contracts? || current_user.admin?)` in views, should be moved to model. E.g.:
```
def contract_manager
  current_user.can_manage_contracts? || current_user.admin?
end
```

2. What about un-met plans?
- Help Rebero see work to be accomplished by Sector

3. Deleting a (duplicate) Facility that has associated Reports:
- Need to re-assign reports before deleting facility
- or create a Merge function?

4. technology_path(:id)
- Add Plan button does nothing

5. Feature tests

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
  `User.first.reset_password('password', 'password')`
* byebug commands
    continue   -- Runs on
    delete     -- Deletes breakpoints
    finish     -- Runs the program until frame returns
    irb        -- Starts an IRB session
    kill       -- Sends a signal to the current process
    quit       -- Exits byebug
    restart    -- Restarts the debugged program
