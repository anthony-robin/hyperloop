# Hyperloop 🚄

Speed up your new Rails 7.1 projects with a preconfigured set of tools !

> [!NOTE]
> This template has been built to match as best as possible default changes I make on every new Rails project I work on. It is very opinionated for some configuration so feel free to fork it and adapt it according to your needs.

## Usage

If you don't have yet the project cloned, fetch it from remote URL:

```shell
$ rails new myapp -m https://raw.githubusercontent.com/anthony-robin/hyperloop/master/template.rb
```

If you already cloned it:

```shell
$ rails new myapp -m hyperloop/template.rb
```

Wait for the end of the installer, then start it with:

```shell
$ bin/dev
```

## Tools

### Gems

In production:

- [sqlite3](https://github.com/sparklemotion/sqlite3-ruby) adapter by default and [pg](https://github.com/ged/ruby-pg) available with a quick change in `database.yml`
- [turbo-rails](https://github.com/hotwired/turbo-rails) and [stimulus-rails]() for javascript related features
- [slim-rails](https://github.com/slim-template/slim-rails) for views templates
- [tailwindcss-rails](https://github.com/rails/tailwindcss-rails) as frontend framework
- [solid_queue](https://github.com/basecamp/solid_queue) as production job adapter
- [sorcery](https://github.com/Sorcery/sorcery) as authentication
- [simple_form](https://github.com/heartcombo/simple_form/) for handling forms inputs
- [pagy](https://github.com/ddnexus/pagy) for pagination
- [meta-tags](https://github.com/kpumuk/meta-tags) for SEO friendly
- [action_policy](https://github.com/palkan/action_policy) as authorization actions verifier
- [dotenv-rails](https://github.com/bkeepers/dotenv) to handle `.env` files
- [activestorage](https://github.com/rails/rails/tree/main/activestorage) and [actiontext](https://github.com/rails/rails/tree/main/actiontext) available by default
- [ffaker](https://github.com/ffaker/ffaker) to generate fake data (seed database)

In development:

- [annotate](https://github.com/ctran/annotate_models) to print model database structure (opinionated configuration)
- [brakeman](https://github.com/presidentbeef/brakeman) to check for security vulnerability in code
- [bullet](https://github.com/flyerhzm/bullet) to track N+1 queries
- [chusaku](https://github.com/nshki/chusaku) to print routes URL above controller actions
- [letter_opener](https://github.com/ryanb/letter_opener) to intercept emails and print them in browser
- [ruby-lsp-rails](https://github.com/Shopify/ruby-lsp-rails) to have better rails integration into editor
- [rubocop](https://github.com/rubocop/rubocop) and its extensions for coding conventions (very opinionated)

### Frontend

- [TailwindCSS](https://tailwindcss.com/)
- [Flowbite](https://flowbite.com/) for responsive navbar and sidebar 

### Features

- Sorcery comes with `session`, `registration` and `reset password` features preconfigured as well as related mailers.
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
