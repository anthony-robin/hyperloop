# Hyperloop 🚄

Speed up your new Rails 8.0 projects with a preconfigured set of tools !

> [!NOTE]
> This template has been built to match as best as possible default changes I make on every new Rails project I work on. It is very opinionated for some configuration so feel free to fork it and adapt it according to your needs.

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
> Some arguments from the `rails new` command might not be compatible with the template. Here are some flags that works well:
>
> ```bash
> $ rails new myapp -m hyperloop/template.rb --css=tailwind --skip-ci --skip-test --skip-system-test --skip-brakeman --skip-active-storage --skip-action-text --skip-action-mailbox --skip-kamal --skip-git
> ```

Wait for the end of the installer, then start it with:

```shell
$ bin/dev
```

## Tools

### Gems

In production:

- [turbo-rails](https://github.com/hotwired/turbo-rails) and [stimulus-rails]() for javascript related features
- [slim-rails](https://github.com/slim-template/slim-rails) for views templates
- [tailwindcss-rails](https://github.com/rails/tailwindcss-rails) as frontend framework (require `--css=tailwind` flag in the command line)
- [simple_form](https://github.com/heartcombo/simple_form/) for handling forms inputs
- [pagy](https://github.com/ddnexus/pagy) for pagination
- [meta-tags](https://github.com/kpumuk/meta-tags) for SEO friendly
- [action_policy](https://github.com/palkan/action_policy) as authorization actions verifier (only if authentication is `yes`)
- [dotenv-rails](https://github.com/bkeepers/dotenv) to handle `.env` files
- [activestorage](https://github.com/rails/rails/tree/main/activestorage) and [actiontext](https://github.com/rails/rails/tree/main/actiontext) available by default
- [ffaker](https://github.com/ffaker/ffaker) to generate fake data (seed database)
- [mission_control-jobs](https://github.com/rails/mission_control-jobs) to manage processed jobs

In development:

- [annotaterb](https://github.com/drwl/annotaterb) to print model database structure (opinionated configuration)
- [bullet](https://github.com/flyerhzm/bullet) to track N+1 queries
- [chusaku](https://github.com/nshki/chusaku) to print routes URL above controller actions
- [letter_opener_web](https://github.com/fgrehm/letter_opener_web) to intercept emails and print them in browser
- [rubocop](https://github.com/rubocop/rubocop) and its extensions for coding conventions (very opinionated)
- [ribbonit](https://github.com/anthony-robin/ribbonit) to display Ruby and Rails informations
- [spark](https://github.com/hotwired/spark) to reload browser page on HTML, CSS, JS modifications.

### Frontend

- [TailwindCSS](https://tailwindcss.com/)
- [Flowbite](https://flowbite.com/) for responsive navbar and sidebar

### Features

- Rails authentication comes with `session`, `registration` and `reset password` features preconfigured as well as related mailers.
- SEO is preconfigured to work in any pages by default and title/description can be specified directly in `seo.{locale}.yml` file.
- Default browser confirm modal as been replaced with a pretty and friendly one following excellent [gorails tutorial](https://gorails.com/episodes/custom-hotwire-turbo-confirm-modals)
- Database is seed with default users corresponding to each access level
- If using `postgres` adapter, database can be dockerized using:

  ```shell
  $ docker-compose up -d
  ```

- Project is configured for french and english locales

## Roadmap

See [Github project](https://github.com/users/anthony-robin/projects/2) for coming roadmap.

## Credits

Hyperloop is inspired by:

- projects developed for [La Voix du Chat Artiste](https://github.com/La-Voix-du-chat-artiste/)
- [excid3/jumpstart](https://github.com/excid3/jumpstart) for its starter template
- [bdavidxyz/tailstart](https://github.com/bdavidxyz/tailstart) for its starter instructions

Thank you :)
