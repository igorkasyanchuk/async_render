# AsyncRender 🚀

A Rails gem that enables asynchronous view rendering with warmup capabilities and in-memory memoization to significantly improve your application's performance.

## Features

### 🔄 Async Rendering
Render multiple view partials asynchronously in background threads, reducing overall page load time by executing independent renders concurrently.

### 🔥 Warmup Rendering
Pre-render partials in your controller actions before the main view is processed. This allows expensive computations to start early and be ready when needed.

### 💾 Memoized Rendering
Cache rendered partials in memory across requests within the same Ruby process, eliminating redundant rendering of static or rarely-changing content.

### ⚡ Smart Thread Pool Management
Automatically configures thread pool size based on your database connection pool and Rails configuration to prevent resource contention.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'async_render'
```

And then execute:

```bash
bundle install
```

### Generator

After installation, run the generator to create an initializer:

```bash
rails generate async_render:install
```

This will create `config/initializers/async_render.rb` with all available configuration options.

## Configuration

The initializer file allows you to configure AsyncRender:

```ruby
AsyncRender.configure do |config|
  # Enable/disable async rendering (default: true)
  config.enabled = Rails.env.production?
  
  # Timeout for async operations in seconds (default: 10)
  config.timeout = 10
  
  # Custom thread pool executor (optional)
  # config.executor = Concurrent::FixedThreadPool.new(10)
  
  # Custom state serialization for thread-local data (optional)
  # config.dump_state_proc = -> { { current_user: Current.user&.id } }
  # config.restore_state_proc = ->(state) { Current.user = User.find_by(id: state[:current_user]) }
end
```

## Usage

### Controller Setup

Include the controller concern in your `ApplicationController`:

```ruby
class ApplicationController < ActionController::Base
  include AsyncRender::Controller
end
```

### Async Rendering

Use `async_render` in your views to render partials asynchronously:

```erb
<!-- app/views/products/show.html.erb -->
<div class="container">
  <%= async_render 'shared/expensive_sidebar', user: current_user %>
  
  <div class="main-content">
    <%= @product.name %>
  </div>
  
  <%= async_render 'products/recommendations', product: @product %>
</div>
```

### Warmup Rendering

Pre-render partials in your controller to start expensive operations early:

```ruby
class ProductsController < ApplicationController
  include AsyncRender::Warmup
  
  # Define warmups for specific actions
  warmups only: [:show] do
    warmup_render 'shared/expensive_sidebar', user: current_user
    warmup_render 'products/recommendations', product: @product
  end
  
  def show
    @product = Product.find(params[:id])
  end
end
```

Then use the warmed-up partials in your views:

```erb
<!-- The warmup_render in the controller pre-calculates these -->
<%= async_render 'shared/expensive_sidebar', user: current_user %>
<%= async_render 'products/recommendations', product: @product %>
```

### Memoized Rendering

For content that rarely changes, use memoized rendering to cache results in memory:

```erb
<!-- This will be rendered once and cached in memory -->
<%= memoized_render 'shared/footer' %>

<!-- With locals - cached based on the locals hash -->
<%= memoized_render 'users/avatar', user: current_user %>

<!-- With custom formats -->
<%= memoized_render 'api/response', { user: @user }, formats: [:json] %>
```

### Clearing Memoized Cache

Clear the memoized cache when needed:

```ruby
# In a rake task or console
AsyncRender.reset_memoized_cache!

# In a controller callback
after_action :clear_cache, only: [:update]

private

def clear_cache
  AsyncRender.reset_memoized_cache! if some_condition?
end
```

## How It Works

1. **Async Rendering**: When you use `async_render`, the gem returns a placeholder immediately and schedules the actual rendering in a background thread
2. **Middleware Processing**: A Rack middleware intercepts the response and replaces placeholders with the actual rendered content
3. **Thread Safety**: The gem handles thread-local state properly, ensuring CurrentAttributes and other thread-local data work correctly
4. **Automatic Pool Sizing**: Thread pool size is automatically determined based on your database pool size and Rails configuration

## Best Practices

### ✅ Do

- Use async rendering for expensive, independent view components
- Warmup partials that you know will be needed
- Memoize static or rarely-changing content
- Monitor your database connection pool usage

### ❌ Don't

- Use async rendering for trivial partials (overhead may exceed benefits)
- Share mutable state between parallel renders
- Rely on request-specific data without proper state management
- Use excessive async rendering that could exhaust database connections

## Performance Considerations

- The gem automatically limits parallelism based on available database connections
- Default timeout is 10 seconds for async operations
- Memoized content persists for the lifetime of the Ruby process
- Consider memory usage when memoizing large amounts of content

## Requirements

- Rails 5.2+
- Ruby 2.7+
- Thread-safe database adapter (PostgreSQL, MySQL, etc.)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/igorkasyanchuk/async_render.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).