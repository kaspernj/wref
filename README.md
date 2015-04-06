# Wref

Weak references for Ruby

## Install

Add to your Gemfile and bundle

```ruby
gem "wref"
```

## Usage

### Make a new weak reference

```ruby
str = "Test"
weak_ref = Wref.new(str)
```

### Check if reference is still alive

```ruby
weak_ref.alive? #=> true | false
```

### Weak map

```ruby
weak_map = Wref::Map.new
map[1] = str
```

### Check if key is valid in a weak map.

```ruby
weak_map.valid?(1) #=> true | false
```

### Get from a key

```ruby
weak_map.get(1) #=> "Test" | Error - Wref::Recycled
```

## Contributing to wref

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Kasper Johansen. See LICENSE.txt for
further details.

