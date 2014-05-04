Happiness Poll
==============

Measure the happiness of your team with this polling site! Take a test drive at http://happiness-poll.herokuapp.com/.

Local Setup
-----

```
git clone git@github.com:scottsbaldwin/happiness_poll.git
bundle install
export PORT=5000
foreman start web
````

Analytics
----

Google analytics is included, but in order to track properly, you will need to set environment variables for:

- ANALYTICS_PROPERTY_ID: The Google Analytics property ID, e.g. UA-*
- ANALYTICS_DOMAIN: The domain you are tracking, e.g. happiness-poll.herokuapp.com

If both variables are set, tracking will be included in the views. If at least one is missing, tracking will be excluded in the views.

If you deploy to Heroku, edit your app settings and create config variables for ANALYTICS_PROPERTY_ID and ANALYTICS_DOMAIN.
