# POST C4G:
* Story:
  - Handle rotate_image()
  - live test the image processes: In the controller, call localize_image!(image_io), which calls resize_image. Then save the image to use the callbacks.
* Story _form:
  - Handle eager-loading stories
  - Handle rotating images (on new and edit)

# NEXT MERGE:
* Need to re-save every report for AddPlanIDToReports && AddYearAndMonthToReports
* There are 7 meaningless distribution reports: `Report.distributions.where(impact: 0)`
* There are 17 meaningless check reports: `Report.checks.where(checked: 0)`
* Run `Story.where.not(image: nil).each { |story| story.migrate_image_name }`, then create a migration to drop `Story#image` column

# from amanda
* Try to make it feel like we're on 20L/blog/updates to some extent.
* Dashboard stats: bigger #s, vertically center in box
* Dasboard collection: banding on bottom of photo instead of card text (brand style banding).
* Story#show: banner image universal (jerrycans), show image in body of page, next to story title and text. Then put "back" and "donate buttons over top of it".
* Spell check story input?
* Add technology to Story#show info section

# CURRENT:

# More reports:
* Last Month:
- Display reports by month (a way for Rebero to easily check his submissions)

* By Geography:
- villages#index is too complex to bother with?
- villages#show
--> by facilities per village, using Plan
--> by technologies, using Target

- facilities#index
  -- make searchable?
  -- communicate if a RWHS or SAM2 is present / planned
- facilities#show is pointless?

* By MOU
- contracts#index && contracts#show
-- By technology: [Report.distributed | Target.goal | Report.impact | Target.people_goal ]
-- By sector: [ Report.impact | Target.people_goal ]

* 'Add plan' && 'Add report' buttons on technologies#show?by_sector don't do anything, but should
- POLICED by current_user.can_create('Report') && current_user.can_create('Plan')
- Since they vary in their provided params [and since sector/id/report relies on date and tech], we should go to a chooser that considers the provided params.

* technologies#show?by_mou could have 'Add Target' button if it's missing, but these should be pre-built with each new MOU

* technologies#index should also have buttons? [Add Plan, Add Report, Add Target]

# Creating/Updating Targets

# Creating/Updating Plans
* Copy the sector/select && sector/#id/report process

# Forms
-- redirect_back on model#create and #update isn't UX
- Tech form
- Contract form
- Target form
- Plan form
- Dist form
- Sector form
- Cell form
- Village form
+ Facility form (also submits as partial from SectorsController#Reports)
  -- CHECK: Sector lookup is showing the record, not the record.name

# Remind myself:
* magic_frozen_string_literal . #get those frozen string benefits
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
