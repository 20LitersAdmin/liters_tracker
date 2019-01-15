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

# Beta bugs:
* Technnology#index math doesn't match Technology#show

# More reports:
* By Geography:
- sectors#show
--> by villages per sector, using Plan
--> by technologies

* By MOU
- contracts#index && contracts#show
-- By technology: [Report.distributed | Target.goal | Report.people_served | Target.people_goal ]
-- By sector: [ Report.people_served | Target.people_goal ]

# Remind myself:
* magic_frozen_string_literal . #get those frozen string benefits
