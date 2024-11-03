# WanderWise
The application's purpose is to help users searching for flight deals to get relevant extra info on the side. We fetch news articles regarding the destination from external API, and serve info based on previous searches, stored in our database.


# Purpose

WanderWise is a **travel tool** designed to empower users to make more informed and exciting **travel plans** by pairing **flight deal** recommendations with real-time **destination** insights. This application aims to reduce the time and effort involved in finding affordable **flight** options while enhancing trip readiness with practical, location-specific information. WanderWise is for travelers who want more than just flights — they want a smart, context-rich view of their **destination**, including **articles**, **itinerary**, and other useful local insights.

# Problem Statement

Planning trips often involves juggling multiple information sources: flight comparison sites, news feeds, and event listings. WanderWise tackles this by consolidating these elements, providing users with:

- The best flight deals for their travel preferences.
- Real-time updates on local events, news articles, and tips specific to their destination. This reduces the need to switch between platforms, making travel planning more streamlined, efficient, and enjoyable.
- Travel itinerary based on the time spent in the country.

# Key Concepts

- Travel Deal: A flight option matched to user criteria, rated based on historical price trends and destination popularity. Each travel deal includes key metrics like current price and historical comparison.
- Destination Insight: A curated feed of information tailored to the user’s destination, including local news, event updates, and seasonal travel tips to help travelers prepare.
- Flight: Represents individual flight options with attributes such as price, duration, airline, and departure/arrival dates.
- Local Events: Key events happening in the travel destination during the planned travel period, sourced to enhance the user’s trip experience.

## Entities

- Flight
- Article

# Install

## Setting up the project

- Copy `secrets_example.yml` to `secrets.yml` and update API tokens
- Ensure Ruby is updated
- Run `bundle install`

## Running the project

```
rake
```
For the rakefile's default, set to run the application with RACK_ENV=development
 
```
bundle exec puma
```
Also works

## Testing the project
```
rake test
````
runs all the tests and creates a merged coverage report
Note that ENV['RACK_ENV'] = 'test' in spec_helper.rb ensures correct environment
