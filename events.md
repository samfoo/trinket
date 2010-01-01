Events Summary
==============

Events are actions triggered by the API which may lead to badges being awarded
to a user.

Types of Events
===============

* Creation (create)

Creation events should occur when an issue is created. There is no value for
this event, but the entity id should be included.

* Status change (status)

Status changes occur when the user alters the state of an issue (e.g. changing
a bug from "open" to "resolved". The value of the event is the new status and 
the entity id should be included.

* Priority change (priority)

Priority changes occur when the user alters the status of an issues priority.
The value of the event is the new priority and the entity id should be 
included.
