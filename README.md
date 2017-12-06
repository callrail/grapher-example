# README

## Table of Contents
1. The What
2. The How
3. The Organization
4. The Running


### The What

`Grapher` is an exercise is implementing usage of the CallRail API. This is intended to serve as a practical example of what can be done with CallRail's API within a Rails project. At it's core, `Grapher` is a simple dashboard app that displays 3 graphs. The information displayed via these graphs reflects call data within a specific time frame. By using the dropwodn menus located at the top of the page, you can narrow down the call data by date range and call tag.

### The How

We make use of two different endpoints for our API calls within the app. First, there is the `call summary` endpoint. This endpoint does a wonderful job of combining the data grouped by a a certain thing (example: grouped by keywords). The other endpoint we use in this app is the `timeseries` endpoint, which is best utilized if you are wanting to retrieve aggregate call data for an account or company, grouped by date. Time series response data is intended to be displayed as a chart, so there tends to be less manipulating of the returned data in the Rails `Charts` Controller

We chose to use these end points because they offer detailed summaries of the data we are looking for. Instead of querying the API every 5 minutes around the clock to get the new call data, we can send 1 API query and get the relevant data. Also, pinging the summary and timeseries endpoints removes information that we do not need for our purposes (example: we do not need a recording URL if all we want to know is how many calls came in on a certain day).



### The Organization

This project follows conventional Ruby on Rails project layouts. To find the bulk of the code added, you can find it in `app/controllers/charts_controller.rb`. Changes were made to the view which can be found in `app/views/charts/index.html.erb`. There was also some minor JQuery used to create the dropdown menus, which can be found in `app/assets/javascripts/the_charts.js`.

For simplicity, we do not load anything via AJAX.

This project utilizes two gems that are outside of the usual gems included in a Rails project. We make use of the [Chartkick](https://www.chartkick.com/) gem to create our beautiful graphs. You can see where we used it in the charts index (`app/views/charts/index.html.erb`)file. Usage includes the variables `bar_chart`, `area_chart`, and `pie_chart`. These variables are made available by the inclusion of the Chartkick gem.

The second non-standard gem we use is [dotenv](https://github.com/bkeepers/dotenv). This gem allows us to store our sensitive account information without fear of exposure when pushing code to public repositories. Additionally, dotenv is a convenient place to store all of your environment variables (those which may change between deployment environments–such as resource handles for databases or credentials for external services). You will see use of dotenv in our `api_request` method in our charts controller. Whenever you see something like `#{ENV['ACCT_ID']}`, you are seeing dotenv at work.

### The Running

TL;DR version:
```
- Get a CallRail Account
- Generate a CallRail API key
- Clone this repository
- cd into the created directory
- bundle install
- in your terminal `rails s`
- open a browser and navigte to localhost:3000
```

If you would like to get this example running locally, you may clone this repo to your machine and run it from there. You will need a CallRail account (you can sign up for a [14 day free trial](https://www.callrail.com/pricing/) without a credit card) and a CallRail API key. Once you have a CallRail account, you can generate an API key by [signing in](https://app.callrail.com/users/sign_in) to CallRail. Next, click on your name in the top right corner. Then click on "view profile". Next, click the link for "API Keys" under the "Security" section on the left side of the screen. Finally, click the "+ Create New API V2 Key" button at the top right.

Once you have your CallRail API Key, you will want to [clone this repository](https://help.github.com/articles/cloning-a-repository/). Once you have this repository cloned to your local desktop, in your terminal, change the current working directory to the newly created folder. Once you are inside of the correct working directory, run `bundle install` from your terminal. This will install the necessary gems to run this web app.

Once the bundle installation is complete, run `rails server` in your terminal. This will start the rails server. Once the server is running, open up your favorite internet browser (we used Chrome for developing this app) and navigate to `localhost:3000`. Once that page loads, you should see 3 graphs and two dropdown menus. Feel free to change these menu selections and see how the graphs change.









???? HOW DO WE GET THE USERS TO HAVE VALID API ACCESS KEYS AND STILL HAVE DATA FOR THE GRPAHS TO DISPLAY????


















