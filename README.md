# LITERS TRACKER
A custom reporting app for 20 Liters

DONE: just use #index for reports instead of #all? E.g. technologies

* 'Add plan' && 'Add report' buttons on technologies#show?by_sector don't do anything, but should
- POLICED by current_user.can_create('Report') && current_user.can_create('Plan')

* technologies#show?by_mou could have 'Add Target' button if it's missing, but these should be buit with each new MOU

* technologies#index should also have buttons? [Add Plan, Add Report, Add Target]

* Submitting a report needs to be intuitive for the user
-- Each technology independently
--- Tech.scale == "Family", show villages, Tech.scale == "Community", show facilities
--- Add facilities on the fly
--- SAM3 should have # of people served (for greater accuracy), default to 5 on Report.people_served

# More reports:
* By Geography:
- sectors#show
--> by cells per sector, using Plan, loop over technologies to include distributed.
--> by technologies, using Target

- cells#index
--> comparable to sectors#index

- cells#show
--> by villages per sector, using Plan
--> by technologies, using Target

- villages#index is too complex to bother with?
- villages#show
--> by facilities per village, using Plan
--> by technologies, using Target

- facilities#index - make searchable?
- facilities#show is pointless?

* By MOU
- contracts#index && contracts#show
-- By technology: [Report.distributed | Target.goal | Report.people_served | Target.people_goal ]
-- By sector: [ Report.people_served | Target.people_goal ]

# Creating Targets

# Creating Plans

# Creating Reports

# Managing User Permissions
- Nest permissions in user routes since it depends on a user
- Or handel all within custom user routes and kill the permissions_controller <-- probably this

# Improvements
- Districts#index doesn't have [Add Plan, Add Report, Add Target] functionality
- Technologies#index doesn't have [Add Plan, Add Report, Add Target] functionality


# Remind myself:
* magic_frozen_string_literal . #get those frozen string benefits
