# Docs Doctor

[![Build Status](https://travis-ci.org/codetriage/docs_doctor.svg?branch=master)](https://travis-ci.org/codetriage/docs_doctor)

## Manifesto

Having well documented methods and classes makes it much easier for coders to become contributors. This lib is intended to help maintainers and contributors find missing or lacking docs and fix them.

Want to get an easy commit on an open source project?

- Write some docs

Want to understand the internals of a project better?

- Write some docs

Want to make the world a better place for you and for future coders?

- Write some docs

## How

We use industry standard doc parsers (starting with RDoc, though other parsers and languages can be added later) to parse documentation for a given library. We store the results and flag undocumented methods/classes. Then anyone can sign up to receive an undocumented piece of code in their inbox.

## Install Locally

Clone the repo then run:

```sh
$ bundle install
```

## Setup Authentication

You'll need to set environment variables for login with GitHub. To do so,
visit https://github.com/settings/applications.

Create a new app with these values:
* Application name: [whatever you want]
* Homepage URL: 127.0.0.1:3000
* Application description: [whatever you want]
* Authorization callback URL: http://127.0.0.1:3000/users/auth/github/callback

You'll receive a Client ID and a Client Secret. Then, add them as environment variables.

The simplest way to get up and running is:

```sh
touch .env && echo "GITHUB_APP_SECRET=[your app secret here]\nGITHUB_APP_ID=[your app id here]" > .env
```

Restart your server to pick up these changes.

## Import from Local rails/rails


```ruby
reload!
repo    = Repo.where(full_name: "schneems/threaded").first_or_create
fetcher = GithubFetcher.new(repo.full_name)
parser  = DocsDoctor::Parsers::Ruby::Yard.new(fetcher.clone)
parser.process
parser.store(repo)
puts DocFile.last.path
```

```ruby
repo    = Repo.where(full_name: "rails/rails").first_or_create
files   = '/Users/schneems/documents/projects/rails/**/*.rb'
files   = '/Users/schneems/Documents/projects/rails/activerecord/lib/rails/generators/active_record/model/model_generator.rb'
parser  = DocsDoctor::Parsers::Ruby::Rdoc.new(files)
parser.process
parser.store(repo)
# DocFile.destroy_all repo = Repo.last
doc  = repo.methods_missing_docs.first
GithubUrlFromBasePathLine.new(doc.repo.github_url, doc.doc_file.path, doc.line).to_github


repo    = Repo.where(full_name: "rails/rails").first_or_create
files   = '/Users/schneems/documents/projects/rails/**/*.rb'
parser = DocsDoctor::Parsers::Ruby::Rdoc.new(files)
parser.process
parser.store(repo)

# DocFile.destroy_all repo = Repo.last
doc  = repo.methods_missing_docs.first
```

* https://github.com/schneems/threaded_in_memory_queue/blob/master/threaded_in_memory_queue/test/threaded_in_memory_queue/master_test.rb/#L5

* https://github.com/schneems/threaded_in_memory_queue/blob/master/test/threaded_in_memory_queue/master_test.rb#L5



## Grab all subscriptions, pull out one doc_method from each


```ruby
reload!
fetcher = GithubFetcher.new(full_name)
parser  = DocsDoctor::Parsers::Ruby::Rdoc.new(fetcher.clone)
parser.process
parser.store(Repo.where("full_name" => full_name).first)
```



# Current Status

- Debug emails not being sent

```ruby
reload!
repo    = Repo.where(full_name: "schneems/rrrretry").first_or_create
fetcher = GithubFetcher.new(repo.full_name)
parser  = DocsDoctor::Parsers::Ruby::Yard.new(fetcher.clone)
parser.process
parser.store(repo)


parser.yard_objects.select {|o| o.is_a?(YARD::CodeObjects::MethodObject) }
```

## TODO

- Store commit so modifying files don't point to the wrong line (https://github.com/schneems/threaded/blob/master/lib/threaded.rb/#L44)
- Fix class versus instance separator
