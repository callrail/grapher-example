# README

# Table of Contents
1. The Who
2. The What
3. The How
4. The Organization
5. The Running

## The Who (Who is this for?)
This project is intended for anyone who wants to see an example of how to consume CallRail's API. Did you just pick up a customer who uses CallRail's API and have no idea how to implement what you read in the [CallRail API Docs](http://apidocs.callrail.com/)? Are you a novice coder wanting to make a project that uses an API? Do you really like pretty charts? This is the place for you!

Since there is a wide range of people with varying levels of programming experience, the code in this project has been thoroughly (some might say overly) documented. Every attempt was made to make this readme and the comments in the code itself easily readable and understandable. If you have a suggestion on how to make something more understandable, please submit a pull request, or send an email to us at support@callrail.com.

## The What

`Grapher` is an exercise is implementing usage of the CallRail API. This is intended to serve as a practical example of what can be done with CallRail's API within a Rails project. At it's core, `Grapher` is a simple dashboard app that displays 3 graphs. The information displayed via these graphs reflects call data within a specific time frame. By using the dropwodn menus located at the top of the page, you can narrow down the call data by date range and call tag.

## The How

We make use of two different endpoints for our API calls within the app. First, there is the `call summary` endpoint. This endpoint does a wonderful job of combining the data grouped by a a certain thing (example: grouped by keywords). The other endpoint we use in this app is the `timeseries` endpoint, which is best utilized if you are wanting to retrieve aggregate call data for an account or company, grouped by date. Time series response data is intended to be displayed as a chart, so there tends to be less manipulating of the returned data in the Rails `Charts` Controller

We chose to use these end points because they offer detailed summaries of the data we are looking for. Instead of querying the API every 5 minutes around the clock to get the new call data, we can send 1 API query and get the relevant data. Also, pinging the summary and timeseries endpoints removes information that we do not need for our purposes (example: we do not need a recording URL if all we want to know is how many calls came in on a certain day).

## The Organization

This project follows conventional Ruby on Rails project layouts. To find the bulk of the code added, you can find it in `app/controllers/charts_controller.rb`. Changes were made to the view which can be found in `app/views/charts/index.html.erb`. There was also some minor JQuery used to create the dropdown menus, which can be found in `app/assets/javascripts/the_charts.js`.

For simplicity, we do not load anything via AJAX.

This project utilizes three gems that are outside of the usual gems included in a Rails project. We make use of the [Chartkick](https://www.chartkick.com/) gem to create our beautiful graphs. You can see where we used it in the charts index (`app/views/charts/index.html.erb`)file. Usage includes the variables `bar_chart`, `area_chart`, and `pie_chart`. These variables are made available by the inclusion of the Chartkick gem.

The second non-standard gem we use is [dotenv](https://github.com/bkeepers/dotenv). This gem allows us to store our sensitive account information without fear of exposure when pushing code to public repositories. Additionally, dotenv is a convenient place to store all of your environment variables (those which may change between deployment environments–such as resource handles for databases or credentials for external services). You will see use of dotenv in our `api_request` method in our charts controller. Whenever you see something like `#{ENV['ACCT_ID']}`, you are seeing dotenv at work.

The third additional gem we are using is [REST Client](https://github.com/rest-client/rest-client). This is a simple HTTP and REST client for Ruby, inspired by the Sinatra's microframework style of specifying actions: get, put, post, delete. We utilize this gem for handling our API requests.

## The Running

TL;DR version:

```
- Get a CallRail Account
- Generate a CallRail API key
- Clone this repository
- CD into the created directory
- Bundle install
- Set environment variables
- In your terminal `rails s`
- Open a browser and navigte to localhost:3000
```

### Get a CallRail Account
If you would like to get this example running locally, you may clone this repo to your machine and run it from there. You will need a CallRail account (you can sign up for a [14 day free trial](https://www.callrail.com/pricing/) without a credit card) and a CallRail API key. Once you have a CallRail account, you can generate an API key by [signing in](https://app.callrail.com/users/sign_in) to CallRail.

### Generate a CallRail API Key

Next, click on your name in the top right corner. Then click on "view profile". Next, click the link for "API Keys" under the "Security" section on the left side of the screen. Finally, click the "+ Create New API V2 Key" button at the top right.

### Clone this Repository

Once you have your CallRail API Key, you will want to [clone this repository](https://help.github.com/articles/cloning-a-repository/). In short, you will be copying the files for this project found on Github to your local machine, allowing you to make changes to this project on your machine.

### CD into the Created Directory

Once you have this repository cloned to your local desktop, in your terminal, change the current working directory to the newly created folder.

### Bundle Install

Once you are inside of the correct working directory, run `bundle install` from your terminal. This will install the necessary gems to run this web app.

### Set Environment Variables

Once the bundle installation is complete, you will need to set your environment variables. Open up this project in your favorite text editor and create a new file in the `Grapher` folder called `.env`. This is the place where you are going to store your private account information.

#### API Key Variable

First, we want to create a variable for your CallRail Api Key. Inside the newly created `.env` file, write the following `CR_API_KEY=` followed by your API key with no spaces. The line will look some thing like `CR_API_KEY=55f5b555e55a55a5555c55555aed555e`.

#### Account ID Variable

Next, we need to make an environment variable for your account ID by writing `ACCT_ID=5555555555` on a new line in your `.env` file. You can find your account ID in the CallRail dashboard by clicking on your name in the top right hand corner of the CallRail Dashboard and clicking the link for "Manage Account". Alternatively, your account ID can be found in the URL of your CallRail Dashboard, immediately following the `a` in the URL (app.callrail.com/a/{your_account_id}).

#### Company ID Variable

Finally, you will want to create your company ID variable by typing `COM_ID=555555555` on a new line of the `.env` file. Your company ID can be found in the URL of your CallRail Dashboard as a query parameter `?company_id=555555555`.

```
Note: if the CallRail account you are working in has more than 1 company, you will want to
navigate to a page in the CallRail Dashboard that is specific to a company. For instance, the
Call Activity page can show `All Companies` or can be toggled to show a specific company.
Be sure that the buton just to the left of the date range in the top right corner is set to a
specific company, not `All Companies`.
```

Once all the environment variables are set, save the `.env` file. You now have working environment variables.

```
Note: It is highly recommended that you add this file to your `.gitignore` file. This prevents
you from accidentally exposing your private account information and API key to a public
repository. This is accomplished by navigating to the `.gitignore` file in this project and
adding `.env` to the bottom of this file if it is not already present.
```

### Run Rails Server

Now that your environment is set up, you are ready to run `rails server` in your terminal. This will start the rails server. Once the server is running, open up your favorite internet browser (we used Chrome for developing this app) and navigate to `localhost:3000`. Once that page loads, you should see 3 graphs and two dropdown menus. Feel free to change these menu selections and see how the graphs change.



## Did you find a bug?
If you found a bug, or have a change to the code that will make this project better, please feel free to submit a pull request. We appreciate open source contributors!

