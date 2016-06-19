
![Build status](https://api.travis-ci.org/bookingexperts/cthulhu.svg?branch=master "Build status")

# Cthulhu

![Cthulhu, the destroyer of words](Cthulhu.jpg?raw=true "Cthulhu")

By using this gem, you will be able to destroy objects and all of their associated children without fetching them from database or using cascade.

This is useful for big applications that:

 * have foreign keys but you do not want to setup cascades to protect users from removing stuff that they do not mean.
 * Database is too big and you do not want to use ActiveRecord's `dependant: :destroy` for performance reasons.

So as foreign keys are setup, you can not accidentally destroy a record and all of its children by doing something like this in console:

```ruby
User.destroy 1
```

However, if needed, you can remove it by:

```ruby
Cthulhu.destroy! User.find(1)
```

## Transaction

Keep in mind that Cthulhu is destroyer, therefore, it is not wrapped in any transaction. To be safe, you need to call it within a transaction like so:

```ruby
user = User.find 1
User.connection.transaction do
  Cthulhu.destroy! user
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'Cthulhu'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install Cthulhu

## How it works?

Cthulhu crawls over all child associations (AKA `has_many`, `has_one`, `has_and_belongs_to_many`) of given record until it finds a model that does not have any child association and starts deleting records until it can destroy the actual record.

So if you have an application that its database looks like this:

```

     users
   /   |   \
posts  |    \
|   \  |     \
 \ comments  |
  \    |    /
   \   |   /
    \  |  /
    images

```
(see test/models.rb)

You can expect the following queries to be executed if you do `Cthulhu.destroy! User.find(5)`

```sql
-- images that belong to #5's posts
DELETE FROM "images"
WHERE  "images"."id" IN (SELECT "images"."id"
                         FROM   "images"
                                INNER JOIN "posts" AS "t0"
                                        ON "t0"."id" = "images"."imagable_id"
                                           AND "images"."imagable_type" IN (
                                               'Post' )
                                INNER JOIN "users" AS "t1"
                                        ON "t1"."id" = "t0"."user_id"
                         WHERE  "t1"."id" = 5);

-- images that belong to #5's comments
DELETE FROM "images"
WHERE  "images"."id" IN (SELECT "images"."id"
                         FROM   "images"
                                INNER JOIN "comments" AS "t0"
                                        ON "t0"."id" = "images"."imagable_id"
                                           AND "images"."imagable_type" IN
                                               ( 'Comment' )
                                INNER JOIN "posts" AS "t1"
                                        ON "t1"."id" = "t0"."post_id"
                                INNER JOIN "users" AS "t2"
                                        ON "t2"."id" = "t1"."user_id"
                         WHERE  "t2"."id" = 5);

-- Comments of #5's posts
DELETE FROM "comments"
WHERE  "comments"."id" IN (SELECT "comments"."id"
                           FROM   "comments"
                                  INNER JOIN "posts" AS "t0"
                                          ON "t0"."id" = "comments"."post_id"
                                  INNER JOIN "users" AS "t1"
                                          ON "t1"."id" = "t0"."user_id"
                           WHERE  "t1"."id" = 5);

-- #5's posts
DELETE FROM "posts"
WHERE  "posts"."id" IN (SELECT "posts"."id"
                        FROM   "posts"
                               INNER JOIN "users" AS "t0"
                                       ON "t0"."id" = "posts"."user_id"
                        WHERE  "t0"."id" = 5);

-- #5's comments
DELETE FROM "comments"
WHERE  "comments"."id" IN (SELECT "comments"."id"
                           FROM   "comments"
                                  INNER JOIN "users" AS "t0"
                                          ON "t0"."id" = "comments"."user_id"
                           WHERE  "t0"."id" = 5);

-- #5's images
DELETE FROM "images"
WHERE  "images"."id" IN (SELECT "images"."id"
                         FROM   "images"
                                INNER JOIN "users" AS "t0"
                                        ON "t0"."id" = "images"."user_id"
                         WHERE  "t0"."id" = 5);

-- #5
DELETE FROM "users"
WHERE  "users"."id" = 5;
```

In above scenario, it is possibly to nullify the comments and images of user instead of removing them completely without changing anything in actual association:

```ruby
Cthulhu.destroy! User.find(5),
  blacklisted: [],
  not_to_be_crawled: [],
  overrides: {
    User => {
      comments: {
        dependent: :nullify
      },
      uploaded_images: {
        dependent: :nullify
      }
    }
  }
```

Please note that as Cthulhu works based on crawling associations, you need to provide `inverse_of` option for associations that ActiveRecord can not determine by itself.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bookingexperts/cthulhu.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
