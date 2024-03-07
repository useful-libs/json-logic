# Contributing

We love pull requests from everyone. By participating in this project, you
agree to abide by the [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)

Fork, then clone the repo:

    git clone git@github.com:your-username/json_logic_ruby.git

Set up your machine:

    bundle install

Make sure the tests pass:

    rspec

Make your change. Add tests for your change. Make the tests pass:

    rspec

Push to your fork and [submit a pull request][pr].

[pr]: https://github.com/useful-libs/json_logic_ruby/compare/

At this point you're waiting on us. We like to at least comment on pull requests
within three business days (and, typically, one business day). We may suggest
some changes or improvements or alternatives.

Some things that will increase the chance that your pull request is accepted:

* Write tests.
* Write a [good commit message][commit], using also [release-please approach][release-please]

## How to create new release version

1. Make changes to code (make sure to create correct commits with [release-please approach][release-please])
2. Update version in `lib/json_logic/version.rb`
3. Create PR with changes
4. After PR is merged, release-please will create new PR 
5. Merge the final PR

[commit]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[release-please]: https://github.com/googleapis/release-please
