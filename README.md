# ActiveMapper

[![Code Climate](https://codeclimate.com/github/artinboghosian/active_mapper.png)](https://codeclimate.com/github/artinboghosian/active_mapper)

ActiveMapper is a data-mapper using ActiveRecord/Arel as a backend. It allows you to create models using PORO and comes with a Memory adapter which you can use during testing to make your tests faster and not reliant on a database. The only requirements are that your models have an id attribute (auto-incrementing int) and respond to a valid? and .model_name ( ActiveSupport::Name). These can easily be injected into your models by including ActiveModel::Model.

## Installation

Add this line to your application's Gemfile:

    gem 'active_mapper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_mapper

## Usage

    class Post
        include ActiveModel::Model
        
        attr_accessor :id, :title, :content, :status, :created_at, :updated_at
        
        def persisted?
            id
        end
    end
    
    post = Post.new(title: 'Post', content: 'My First Post')
    
    # ActiveMapper[Class] will automatically create and wire up the mapper
    # if it does not exist. The only requirement is that the table exists
    # with the proper columns (e.g. use ActiveRecord migrations).
    ActiveMapper[Post].save(post)
    
    record = ActiveMapper[Post].find(post.id)
### Querying
    mapper = ActiveMapper[Post]
    
    # some methods return an ActiveMapper::Relation which will not execute
    # any queries until #to_a, #each or #map are called.
    
    mapper.select { |post| post.title.starts_with('Post') }
    mapper.reject { |post| post.status == 'draft' }
    
    # some methods actually execute the query immediately
    
    mapper.first { |post| !(post.status == 'draft') }
    mapper.last { |post| (post.status == 'published') & (post.created_at > 5.days.ago) }
    mapper.all { |post| (post.content.contains('monkey')) & (post.status == 'published) }

## Contributing

1. Fork it ( http://github.com/<my-github-username>/active_mapper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
