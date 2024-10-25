# WanderWise
SOA 2024 UPSTART "Trip Planner"

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