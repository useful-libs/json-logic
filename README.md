# JsonLogic

Build rules and execute them in ruby. See https://jsonlogic.com


## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add json_logic_ruby

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install json_logic_ruby

## Usage
#### Run json-logic:

```ruby
RULE = <<~JSON
  { "and" : [
      {">=" : [ { "var" : "length" }, 15 ]},
      {">=" : [ { "var" : "size" }, 50 ]}
    ] }
JSON

DATA = JSON.parse('{ "length": 20, "size": 49 }')

logic = JsonLogic::Evaluator.new
logic.apply(JSON.parse(RULE), DATA)
```
##### Get all variables used in a rule

```ruby
logic = JsonLogic::Evaluator.new
res = logic.extract_vars(JSON.parse(RULE))
puts res

# will print -> ["length", "size"]
```

##### Track report of all operations
```ruby
logic = JsonLogic::Evaluator.new
logic.apply(JSON.parse(RULE), DATA)

puts logic.tracker.report

# will print
# LOGIC: 'and', RESULT = false
#   DATA: 'length' data:20 >= expected:15,  RESULT = true
#   DATA: 'size' data:49 >= expected:50,  RESULT = false
```


## Development

After checking out the repo, run `bundle install` to install dependencies.

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Json::Logic project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/useful-libs/json_logic_ruby/blob/main/CODE_OF_CONDUCT.md).
