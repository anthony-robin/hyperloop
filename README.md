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
> Some arguments from the `rails new` command might not be compatible with the template.

Generator will ask several questions to refine configuration:
- What port the server should run (default: `3000`)
- What language the app should handle (default: `en`)
- Is an authentication needed ? (default: `true`)
  - If yes, does an admin dashboard is needed ?  (default: `true`)

> [!NOTE]
You can specify the port directly in the generator command using `--port=4000` and avoid the first question prompt:
> ```shell
> $ rails new myapp -m hyperloop/template.rb -- --port=4000
> ```

Wait for the end of the installer, then start it with:

```shell
$ bin/dev
```

## Tools

### Gems

#### In production:

- [simple_form](https://github.com/heartcombo/simple_form/) for handling forms inputs
- [pagy](https://github.com/ddnexus/pagy) for pagination
- [meta-tags](https://github.com/kpumuk/meta-tags) for SEO friendly
- [action_policy](https://github.com/palkan/action_policy) as authorization actions verifier (only if authentication is `yes`)
- [pretender](https://github.com/ankane/pretender) to sign in as another user (only if admin dashboard is `yes`)
- [dotenv-rails](https://github.com/bkeepers/dotenv) to handle `.env` files
- [mission_control-jobs](https://github.com/rails/mission_control-jobs) to manage processed jobs (unless `--skip-active-job` flag)
- [rails-i18n](https://github.com/svenfuchs/rails-i18n) if locale is different of English

#### In development:

- [annotaterb](https://github.com/drwl/annotaterb) to print model database structure (opinionated configuration)
- [bullet](https://github.com/flyerhzm/bullet) to track N+1 queries
- [chusaku](https://github.com/nshki/chusaku) to print routes URL above controller actions
- [letter_opener_web](https://github.com/fgrehm/letter_opener_web) to intercept emails and print them in browser (unless `--skip-action-mailer` flag)
- [rubocop](https://github.com/rubocop/rubocop) and its extensions for coding conventions (opinionated) (unless `--skip-rubocop` flag)
- [ribbonit](https://github.com/anthony-robin/ribbonit) to display Ruby and Rails information
- [spark](https://github.com/hotwired/spark) to reload browser page on HTML, CSS, JS modifications.

#### In test (unless `--skip-test` flag):

- [simplecov](https://github.com/simplecov-ruby/simplecov) to get code coverage of the app
- [ffaker](https://github.com/ffaker/ffaker) to generate fake data (seed database)

### Frontend

- [PicoCSS](https://github.com/Yohn/PicoCSS) as a minimalist prototyping framework.
- [daisyUI](https://daisyui.com/) as a minimalist framework on top of Tailwind (required `--css=tailwind` flag option).

### Features

- Rails authentication comes with `session`, `registration` and `reset password` features preconfigured as well as related mailers.
- A minimal admin dashboard is created if requested on generator prompt. This feature includes the [pretender](https://github.com/ankane/pretender) gem to sign in as another user to manage it easily.
- SEO is preconfigured to work in any pages by default and title/description can be specified directly in `seo.{locale}.yml` file.
- Default browser confirm modal as been replaced with a pretty and friendly one following excellent [gorails tutorial](https://gorails.com/episodes/custom-hotwire-turbo-confirm-modals).
- Database is seed with default users corresponding to each access level.
- If using `postgres` adapter, database can be dockerized using:

  ```shell
  $ docker-compose up -d
  ```

### Locales

Project is compatible for `english` and `french` locales out of the box.

## Roadmap

See [Github project](https://github.com/users/anthony-robin/projects/2) for coming roadmap.

## Credits

Hyperloop is inspired by:

- [excid3/jumpstart](https://github.com/excid3/jumpstart) for its starter template
- [bdavidxyz/tailstart](https://github.com/bdavidxyz/tailstart) for its starter instructions

Thank you :)
