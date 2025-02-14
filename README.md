# Hyperloop 🚄

Speed up your new Rails 8.0 projects with a preconfigured set of tools !

## Usage

If you don't have yet the project cloned, fetch it from remote URL:

```shell
$ rails new myapp -m https://raw.githubusercontent.com/anthony-robin/hyperloop/master/template.rb
```

If you already have it cloned:

```shell
$ rails new myapp -m hyperloop/template.rb
```

> [!WARNING]
> Some arguments from the `rails new` command might not be compatible with the template. Here are some flags that work well:
>
> ```bash
> $ rails new myapp -m hyperloop/template.rb --skip-ci --skip-test --skip-system-test --skip-brakeman --skip-active-storage --skip-action-text --skip-action-mailbox --skip-kamal --skip-git
> ```

Generator will ask several questions to refine configuration:
- What port the server should run (default: `3000`)
- What language the app should handle (default: `en`)
- Is an authentication needed ?
  - If yes, does an admin dashboard is needed ?

Wait for the end of the installer, then start it with:

```shell
$ bin/dev
```

## Tools

### Gems

In production:

- [turbo-rails](https://github.com/hotwired/turbo-rails) and [stimulus-rails]() for JavaScript related features
- [slim-rails](https://github.com/slim-template/slim-rails) for views templates
- [simple_form](https://github.com/heartcombo/simple_form/) for handling forms inputs
- [pagy](https://github.com/ddnexus/pagy) for pagination
- [meta-tags](https://github.com/kpumuk/meta-tags) for SEO friendly
- [action_policy](https://github.com/palkan/action_policy) as authorization actions verifier (only if authentication is `yes`)
- [dotenv-rails](https://github.com/bkeepers/dotenv) to handle `.env` files
- [activestorage](https://github.com/rails/rails/tree/main/activestorage) and [actiontext](https://github.com/rails/rails/tree/main/actiontext) available by default
- [ffaker](https://github.com/ffaker/ffaker) to generate fake data (seed database)
- [mission_control-jobs](https://github.com/rails/mission_control-jobs) to manage processed jobs
- [rails-i18n](https://github.com/svenfuchs/rails-i18n) if locale is different of English

In development:

- [annotaterb](https://github.com/drwl/annotaterb) to print model database structure (opinionated configuration)
- [bullet](https://github.com/flyerhzm/bullet) to track N+1 queries
- [chusaku](https://github.com/nshki/chusaku) to print routes URL above controller actions
- [letter_opener_web](https://github.com/fgrehm/letter_opener_web) to intercept emails and print them in browser
- [rubocop](https://github.com/rubocop/rubocop) and its extensions for coding conventions (very opinionated)
- [ribbonit](https://github.com/anthony-robin/ribbonit) to display Ruby and Rails information
- [spark](https://github.com/hotwired/spark) to reload browser page on HTML, CSS, JS modifications

In test (unless `--skip-test` flag):

- [rspec-rails](https://github.com/rspec/rspec-rails) to test requests, models, mailers, ...
- [simplecov](https://github.com/simplecov-ruby/simplecov) to get code coverage of the app
- [rubocop-rspec](https://github.com/rubocop/rubocop-rspec) to follow rspec related rules and best practices

### Frontend

- [PicoCSS](https://github.com/Yohn/PicoCSS) as a minimalist prototyping framework.

### Features

- Rails authentication comes with `session`, `registration` and `reset password` features preconfigured as well as related mailers.
- A minimal admin dashboard is created if requested on generator prompt. This feature includes the [pretender](https://github.com/ankane/pretender) gem to sign in as another user to manage it easily.
- SEO is preconfigured to work in any pages by default and title/description can be specified directly in `seo.{locale}.yml` file.
- Default browser confirm modal as been replaced with a pretty and friendly one following excellent [gorails tutorial](https://gorails.com/episodes/custom-hotwire-turbo-confirm-modals)
- Database is seed with default users corresponding to each access level
- If using `postgres` adapter, database can be dockerized using:

  ```shell
  $ docker-compose up -d
  ```

### Locales

Project is compatible for `english` and `french` locales out of the box. When generator ask for locales, answer in two letters ISO 639 language code. For multiple locales, separate them with a comma. For example:

```
- en
- fr
- en,fr
```

> [!NOTE]
> In case of multiples locales, the default will be the first one specified.

## Roadmap

See [Github project](https://github.com/users/anthony-robin/projects/2) for coming roadmap.

## Credits

Hyperloop is inspired by:

- [excid3/jumpstart](https://github.com/excid3/jumpstart) for its starter template
- [bdavidxyz/tailstart](https://github.com/bdavidxyz/tailstart) for its starter instructions

Thank you :)
