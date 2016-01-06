[![Code Climate](https://codeclimate.com/github/kaspernj/wref/badges/gpa.svg)](https://codeclimate.com/github/kaspernj/wref)
[![Test Coverage](https://codeclimate.com/github/kaspernj/wref/badges/coverage.svg)](https://codeclimate.com/github/kaspernj/wref)
[![Build Status](https://img.shields.io/shippable/540e7b9f3479c5ea8f9ec25e.svg)](https://app.shippable.com/projects/540e7b9f3479c5ea8f9ec25e/builds/latest)

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

### Spawn a weak map

```ruby
weak_map = Wref::Map.new
```

### Set a key and value in a weak map

```ruby
str = "Test"
map[1] = str
map.set(1, str)
```

### Get values from a weak map

```ruby
map.get(1) #=> "Test" | nil
map.get!(1) #=> "Test" | Wref::Recycled error
```

### Loop over all valid pairs in a weak map

```ruby
map.each do |key, value|
  puts "Valid pair: #{key}: #{value}"
end
```

### Check if key is valid in a weak map.

```ruby
map.valid?(1) #=> true | false
```

### Getting length of both valid and invalid and the current time in a weak map (fastest)

```ruby
map.length #=> 1
```

### Getting length of valid options in a weak map

```ruby
map.length_valid #=> 0
```

### Get from a key

```ruby
map.get(1) #=> "Test" | nil
map.get!(1) #=> "Test" | Error - Wref::Recycled
```

### Delete a key from a weak map

```ruby
map.delete(1) #=> "Test" | nil if recycled
```

### Delete all recycled options

```ruby
map.clean
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

