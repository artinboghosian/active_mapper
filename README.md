# ActiveMapper

ActiveMapper is a implementation of DataMapper pattern using ActiveRecord/Arel as a backend. It allows you to create models using plain old ruby objects so that you can substitute the Memory adapter in tests (which will make them super fast). It assumes that your models have an id field and respond to valid? and .model_name. These can easily be injected into your models by including ActiveModel::Model. It was heavily influenced by the Perpetuity gem (which I love). Also all of your querying is done through procs rather than strings or hashes.

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
    
    ActiveMapper.generate(Post)
    
    post = Post.new(title: 'Post', content: 'My First Post')
    ActiveMapper[Post].save(post)
    
    record = ActiveMapper[Post].find(post.id)
### Querying
    mapper = ActiveMapper[Post]
    
    mapper.where { |post| post.title.starts_with('Post') }
    mapper.first { |post| !(post.status == 'draft') }
    mapper.last { |post| (post.status == 'published') & (post.created_at > 5.days.ago) }
    mapper.all { |post| (post.content.contains('monkey')) & (post.status == 'published) }

Simply create a plain old ruby model (e.g. Post) that includes ActiveModel::Model. Add attr_accessor (must have :id). Then register an adapter using ActiveMapper.generate(Post). Make sure to set the adapter you want to use (default is ActiveMapper::Adapter::Memory). Set the adapter by calling ActiveMapper.adapter = ActiveMapper::Adapter::ActiveRecord.new. Then access the mapper using ActiveMapper[Post]. Please contribute to the project by forking it if you feel this project has any value or you are just interested in it.

## Contributing

1. Fork it ( http://github.com/<my-github-username>/active_mapper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
