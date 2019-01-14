# LITERS TRACKER
A custom reporting app for 20 Liters

DONE: just use #index for reports instead of #all? E.g. technologies

* 'Add plan' && 'Add report' buttons on technologies#show?by_sector don't do anything, but should
- POLICED by current_user.can_create('Report') && current_user.can_create('Plan')

* technologies#show?by_mou could have 'Add Target' button if it's missing, but these should be buit with each new MOU

* technologies#index should also have buttons? [Add Plan, Add Report, Add Target]

# More reports:
* By Geography:
- districts#index (or index) using Plans (not Targets)
--> By MOU (or just rely on searchbar dates?)
--> By Technology

- districts#show (using Plans)
--> By technology
--> By sector

- sectors#index
--> By MOU (or just rely on searchbar dates?)

- sectors#show --> all villages per sector, using Plan

* By MOU
- contracts#index && contracts#show
-- By technology: [Report.distributed | Target.goal | Report.people_served | Target.people_goal ]
-- By sector: [ Report.people_served | Target.people_goal ]

# Remind myself:
* magic_frozen_string_literal . #get those frozen string benefits
