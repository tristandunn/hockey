# Hockey

Fast and minimal list of upcoming NHL games.

Also includes the full upcoming schedule for each team, in addition to language
and locale specific date and time formatting via [Intl.DateTimeFormat][].

## Setup

Install the dependencies.

    bundle install

## Development

To run the server, and build the site when files are changed.

    bundle exec jekyll serve

Before pushing changes, ensure the code builds and the CSS is valid.

    bundle exec jekyll build
    bundle exec scss-lint

## License

Hockey uses the MIT license. See LICENSE for more details.




[Intl.DateTimeFormat]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/DateTimeFormat
