# Docs Doctor

## Manifesto

Having well documented methods and classes make it much easier for coders to become contributors. This lib is intended to help maintainers and contributors find missing or lacking docs and fix them.

Want to get an easy commit on an open source project?

- Write some docs

Want to understand the internals of a project better?

- Write some docs

Want to make the world a better place for you and for future coders?

- Write some docs

## How

We use industry standard doc parsers (starting with RDoc, though other parsers and languages can be added later) to parse documentation for a given library. We store the results and flag undocumented methods/classes. Then anyone can sign up to receive one undocumented piece of code in your inbox

## Install Locally

Clone the repo then run:

```sh
$ bundle install
```



DocProj has many DocFiles
DocFile has many DocClass(es)
DocClass has many DocMethods

DocMethod has many DocComments
DocClass has many DocComments


## Scratch


reload!
repo    = Repo.where_or_create(full_name: "schneems/threaded_in_memory_queue")
fetcher = GithubFetcher.new(repo.full_name)
parser  = DocsDoctor::Parsers::Ruby::Rdoc.new(fetcher.clone)
parser.process
parser.store(repo)
puts DocFile.last.path


repo    = Repo.where_or_create(full_name: "rails/rails")
# files   = '/Users/schneems/documents/projects/rails/**/*.rb'files   = '/Users/schneems/Documents/projects/rails/activerecord/lib/rails/generators/active_record/model/model_generator.rb'parser  = DocsDoctor::Parsers::Ruby::Rdoc.new(files) parser.process parser.store(repo) # DocFile.destroy_all repo = Repo.last
doc  = repo.methods_missing_docs.first
GithubUrlFromBasePathLine.new(doc.repo.github_url, doc.doc_file.path, doc.line).to_github


repo    = Repo.where_or_create(full_name: "rails/rails")
files   = '/Users/schneems/documents/projects/rails/**/*.rb'
parser = DocsDoctor::Parsers::Ruby::Rdoc.new(files)
parser.process
parser.store(repo)

# DocFile.destroy_all repo = Repo.last
doc  = repo.methods_missing_docs.first


https://github.com/schneems/threaded_in_memory_queue/blob/master/threaded_in_memory_queue/test/threaded_in_memory_queue/master_test.rb/#L5

https://github.com/schneems/threaded_in_memory_queue/blob/master/test/threaded_in_memory_queue/master_test.rb#L5




Grab all subscriptions, pull out one doc_method from each
