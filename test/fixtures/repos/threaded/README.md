## Threaded

[![Build Status](https://travis-ci.org/schneems/threaded.png?branch=master)](https://travis-ci.org/schneems/threaded)

Simpler than actors, easier than threads. Get threaded!

## What

Why wait? If you're doing IO in MRI, or really anything in JRuby you can speed up your programs dramatically by using threads. Threads however are a low level primitive in Ruby that can be difficult to use. The `Threaded` library implements a few common thread patterns into an easy to use interface. This lets you focus on writing your code and `Threaded` will worry about running that code as fast as possible.

## Install

In your `Gemfile`:

```ruby
gem 'threaded'
```

Then run `$ bundle install`


# Simple Promises

Throw tasks you want to get worked on in the background into a `Threaded.later` block:

```ruby
promise = Threaded.later do
  require "YAML"
  YAML.load `curl https://s3-external-1.amazonaws.com/heroku-buildpack-ruby/ruby_versions.yml 2>/dev/null`
end
```

Then when you need the value use the `value` method:

```ruby
promise.value # => ["ruby-2.0.0", "ruby-1.9.3", # ...
```

It's secretly doing all of that work in the background letting your main Ruby thread focus on the work you care about most.

## Keep your Promises

Promises will block when executed inside of one another, this means you can put promises in your promises and they'll always be executed in the correct order.

```ruby
curl = Threaded.later do
  `curl https://s3-external-1.amazonaws.com/heroku-buildpack-ruby/ruby_versions.yml 2>/dev/null`
end

yaml = Threaded.later do
  require "YAML"
  YAML.load curl.value
end
```

This code guarantees that the block in `curl` gets executed before the `YAML.load`. Of course, the outcome is the same:

```ruby
yaml.value # => ["ruby-2.0.0", "ruby-1.9.3", # ...
```

While a contrived example, you can use this type of promise chaining to parallelize complex tasks.

By the way, if you call `Threaded.later` and never call `value` on the returned object it may run but is not guaranteed to. So if you `value` your "promises" then you'll always keep them.

## Promise STDOUT behavior

A Threaded `later` block is supposed to look and feel like regular code. The biggest difference is that as soon as you define a `Threaded.later {}` block it begins to run in the background. Nothing throws off the illusion of "normal" code than sporadic random lines in your STDOUT. So by default Threaded captures all promise stdout and only outputs it when `value` is called.

```ruby
task = Threaded.later do
  puts "HEY YOU GUYS!!!!"
  10 * 10
end
```

At this point the task has already run, but `"HEY YOU GUYS!!!"` is nowhere to be seen in STDOUT. It will show up as soon as you request the value


```ruby
puts task.value
HEY YOU GUYS!!!!
# => 100
```

If you don't like this voodoo and want to see really jumbled up STDIO, it's okay. You can set `Threaded.sync_promise_io = false`

```ruby
task = Threaded.later do
  puts "HEY YOU GUYS!!!!"
  10 * 10
end
# => "HEY YOU GUYS!!!"
task.value
# => 100
```

You can also set this value in a `config` block.

## Noisey Shell Sessions

Output from other shell sessions will still show up as soon as they execute.

```
Threaded.later do
  `git clone git@github.com:schneems/threaded.git`
end
=> #<Threaded::Promise:0x007fd51c0a9b98 @mutex=#<Mutex:0x007fd51c0a9b20>, @has_run=false, @running=true, @result=nil, @error=nil, @job=#<Proc:0x007fd51c0a9bc0@/Users/schneems/Documents/projects/threaded/lib/threaded.rb:71>>
remote: Counting objects: 221, done.
remote: Compressing objects: 100% (130/130), done.
remote: Total 221 (delta 115), reused 188 (delta 83)
Receiving objects: 100% (221/221), 29.62 KiB | 0 bytes/s, done.
Resolving deltas: 100% (115/115), done.
```

You can get around this by redirecting the IO:

```
out = `git clone git@github.com:schneems/threaded.git 2>/dev/null`
puts out
```
In bash `1` is stdout, `2` is stderror. You can redirect a stream to another, for example to merge stderr into stdout you could run a command with `2>&1` at the end. To completely disregard output you can send it to `/dev/null` on unix systems.

Note: git does some weird things when you try to redirect stderr to stdio `2>&1` (http://stackoverflow.com/a/18006967/147390).

By using a library to direct the sub shell stdin, stdout, stderr like `Open3`:

```
require 'open3'
Open3.popen3("git clone git@github.com:schneems/threaded.git") do |stdin, stdout, stderr, wait_thr|
  puts stdout.read.chomp
  puts stderr.read.chomp
end
```

Or by running the command in a `--quiet` option if it has one:

```
`git clone git@github.com:schneems/threaded.git --quiet`
```

## Background Queue

The engine that powers the `Threaded` promise is also a publicly available background queue! You may be familiar with `Resque` or `sidekiq` that allow you to enqueue jobs to be run later, threaded has something like that. The main difference is that threaded does not persist values to a permanent store (like Resque or PostgreSQL). Here's how you use it.

Define your task to be processed:

```ruby
class Archive
  def self.call(repo_id, branch = 'master')
    repo = Repository.find(repo_id)
    repo.create_archive(branch)
  end
end
```

It can be any object that responds to `call` but we recommend a class or module which makes switching to a durable queue system (like Resque) easier.

Then to enqueue a task to be run in the background use `Threaded.enqueue`:

```ruby
repo = Repo.last
Threaded.enqueue(Archive, repo.id, 'staging')
```

The first argument is a class that defines the task to be processed and the rest of the arguments are passed to the task when it is run.


# Configure

The default number of worker threads is 16, you can configure that when you start your queue:

```ruby
Threaded.config do |config|
  config.size = 5
end
```

Want a different logger? Specify a different Logger:

```ruby
Threaded.config do |config|
  config.logger = Logger.new(STDOUT)
end
```

As soon as you call `enqueue` a new thread will be added to your thread pool if it is needed. If you wish to explicitly start all threads you can call `Threaded.start`. You can also inline your config if you want when you start the queue:

```ruby
Threaded.start(size: 5, logger: Logger.new(STDOUT))
```

For testing or guaranteed code execution use the `inline` option:

```ruby
Threaded.inline = true
```

This option bypasses the queue and executes code as it comes.

## Thread Considerations

This worker operates in the same process as your app, that means if your app is CPU bound, it will not be very useful. This worker uses threads which means that to be useful your app needs to either use IO (database calls, file writes/reads, shelling out, etc.) or run on JRuby or Rubinius.

All other threading concerns remain true so be careful for using things like `Dir.chdir` inside of threaded as it changes the directory for all threads. Also don't modify shared data (unless you've got a mutex around it and know what you're doing).

It is possible for you to enqueue more things in your queue than can be processed before your program exits (you hit CTRL+C, or get an exception). When your program exits all jobs promises and enqueued jobs go away as they are not persisted to disk. If you care about your data getting run always call `value` on promises. When `value` is called on promises if it has not already started running it will be run immediately. This functionality allows for the chaining of promises.

To truly preserve data you've `enqueued` into Threaded's background queue you need to switch to a durable queue backend like Resque. Alternatively use a promise and call `value` on the `Threaded.later` promise object.

## License

MIT

