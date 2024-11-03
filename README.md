# WanderWise
The application's purpose is to help users searching for flight deals to get relevant extra info on the side. We fetch news articles regarding the destination from external API, and serve info based on previous searches, stored in our database.


## Entities

- Flight
- NY Times article

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
