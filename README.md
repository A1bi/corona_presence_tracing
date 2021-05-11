# CoronaPresenceTracing

This Ruby gem helps you create QR codes and URLs which can be used with COVID-19 contact tracing apps such as the German [Corona-Warn-App](https://www.coronawarn.app/) to check in at events or locations.

The concept of Decentralized Privacy-Preserving Presence Tracing is implemented and referred to as Event Registration in the Corona-Warn-App. Its implementation as described [here](https://github.com/corona-warn-app/cwa-documentation/blob/master/event_registration.md) is comparable to the [CrowdNotifier](https://github.com/CrowdNotifier/documents) proposal.

## Installation

Add this gem to your `Gemfile` and run `bundle install`:

```ruby
gem 'corona_presence_tracing'
```

Or install it yourself:

```console
$ gem install corona_presence_tracing
```

## Usage

First create a `CWACheckIn` instance with attributes that describe your venue or event. The following is an example for a retail store:

```ruby
check_in = CoronaPresenceTracing::CWACheckIn.new(
  description: 'Grocery Store', # max. 100 characters
  address: 'Berlin', # max. 100 characters
  start_time: Time.new(2021, 5, 11, 7, 0), # or a Date or DateTime
  end_time: Time.new(2021, 5, 11, 22, 0), # or a Date or DateTime
  location_type: :permanent_retail, # see below for a list of types
  default_check_in_length: 30 # in minutes, optional for temporary events
)
```

The values you provide are validated and a `CoronaPresenceTracing::ValidationError` will be raised if any of them don't meet the constraints.

These are all possible location types:

permanent                            | temporary
-------------------------------------|---------------------
`:permanent_craft`                   | `:temporary_club_activity`
`:permanent_educational_institution` | `:temporary_cultural_event`
`:permanent_food_service`            | `:temporary_other`
`:permanent_other`                   | `:temporary_private_event`
`:permanent_public_building`         | `:temporary_worship_service`
`:permanent_retail`                  |
`:permanent_workplace`               |

You can now either get just the encoded payload or the full check-in URL:

```ruby
check_in.encoded_payload
# CAESJQgBEg1Hcm9jZXJ5IF...
check_in.url
# https://e.coronawarn.app?v=1#CAESJQgBEg1Hcm9jZXJ5IF...
```

### Creating QR codes

You can easily create check-in QR codes using [RQRCode](https://github.com/whomwah/rqrcode). Just use the URL of a check-in as the payload for the QR code:

```ruby
check_in = CoronaPresenceTracing::CWACheckIn.new(...)
qr = RQRCode::QRCode.new(check_in.url)
svg = qr.as_svg
```

### Decoding

You can also decode an already encoded check-in payload to read its attributes:

```ruby
# with a URL
check_in = CoronaPresenceTracing::CWACheckIn.decode('https://e.coronawarn.app?v=1#CAESJQgBEg...')
# or with just the encoded payload
check_in = CoronaPresenceTracing::CWACheckIn.decode('CAESJQgBEg...')
check_in.description # Grocery Store
check_in.start_time # 2021-05-11 07:00:00
```

Please be aware that if you re-encode these instances you will get a different result as the cryptographic seed inside the payload will not be copied over to the new `CWACheckIn` instance.

## Support for other apps

The check-in payload is designed to support apps from other countries as well. Currently no other apps seem to have implemented it, though. New classes next to `CWACheckIn` with app-specific attributes will be added as soon as this changes.

## License

This gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
