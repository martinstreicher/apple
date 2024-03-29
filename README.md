[![Ruby on Rails CI](https://github.com/martinstreicher/apple/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/martinstreicher/apple/actions/workflows/rubyonrails.yml)

# Weather Forecasting with Rails

This sample application presents an extended weather forecast
for a given address, where an address can be either of a street
address, city and state, or a street address and a zipcode.

Given an address, the application uses a public API to convert
the address to a _(latitude, longitude)_ pair. Next, the coordinates
are passed to another freely-available API to find forecast information,
including URLs for extended data such as a weeklong forecast. Finally,
the application retrieves JSON data from the foreacast endpoint and
presents it. Forecast information for a particular address is cached for
30 minutes.

## Installation

Clone this repo to your development environment, change to the directory
containing the source, and run the following commands. (Configuration files
exist for _rvm_ and _asdf_.)

```bash
bundle install
rspec
rails s
```

Point your browser to `localhost:3000`.

## Configuration

Three environment variables are available to control the behavior of the
application.

* `WEATHER_CACHE_OFF` (default: `false`): If caching is enabled in the
  Rails environment, but `WEATHER_CACHE_OFF` is `true`, no caching occurs.

* `WEATHER_CACHE_EXPIRY_IN_SECONDS` (default: `30 minutes`): Set this
  variable to a number of seconds to control the expiry of cached information.

* `WEATHER_DEBUG_HTTP` (default: `false`): Set this variable to `true`
  to see all network requests and responses made by the application. The
  value of `debug` in the configuration YAML files have precedence.

Configuration of each service -- the geocoder and the forecast lookup --
are controlled by YAML files found in _config/services_.

## Of Interest

* All code has been policed by Rubocop. See [the configuration file](.rubocop.yml)
  for the cops and rules applied. (The Markdown linter has been applied
  to this README.)

* The controllers are very thin, as are the models. The application "glue"
  is provided via a set of services implemented per the Interactor pattern.

* Networking calls can be debugged easily. Simply set `debug: true` in any
  of the network service configurations.

* The code uses a handful of Rails features to make the code more robust
  and modular:
  * Views use _strict locals_, which disables the sharing of instance variables
    between a controller and its partials.
  * A localization file provides for customization of time formats.
  * YAML files are used to configure the endpoints of various services.
  * Turbo is disabled for the application to reduce complexity.

* A minimal but functional Github action has been installed in this repo
  to run tests after each push.

## Colophon

* Built on Rails 7, Ruby 3.2.2, HAML, and no database

* Tests are baed on RSpec, Shoulda, and VCR

* Geocdoding generated by [United States Census Service API](https://geocoding.geo.census.gov/geocoder/Geocoding_Services_API.html)

* Forecasts provided by the [United States National Weather Service API](https://weather-gov.github.io/api/general-faqs)

For a complete list of gems used in the application, see

## Room for Improvement

The application follows Rails best practices, but could be made more
feature-rich. Some areas for improvement:

* Integrate _anyway_config_ for more flexible configuration, including
  "dot" files, environment variables, and Rails secrets.

* Enable and use Turbo, Hotwire, and Stimulus to provide single-page application
  behaavior and real-time forecase updates.

* Implement more integration tests and include the _climate_control_ gem
  to test environment variables.

* Add the _Tailwind_ CSS framework or its ilk and style pages.
