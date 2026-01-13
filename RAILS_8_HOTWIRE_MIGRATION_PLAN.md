# Rails 8 + Hotwire Native Migration Plan

**Decision**: Hotwire + Turbo Native ✅

**Goals**:
1. Maximum easy maintenance
2. Enable JS developer to work independently
3. Build native iOS/Android apps from same codebase
4. 95% code sharing between web and mobile

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Current State](#current-state)
3. [Target Architecture](#target-architecture)
4. [Why Hotwire + Turbo Native](#why-hotwire--turbo-native)
5. [Migration Timeline](#migration-timeline)
6. [Detailed Migration Steps](#detailed-migration-steps)
7. [Code Examples & Conversions](#code-examples--conversions)
8. [Division of Work](#division-of-work)
9. [Frontend Developer Onboarding](#frontend-developer-onboarding)
10. [Development Workflow](#development-workflow)
11. [Testing Strategy](#testing-strategy)
12. [Deployment](#deployment)
13. [Success Metrics](#success-metrics)

---

## Executive Summary

### Current State
- **Rails**: 7.0.8
- **Ruby**: 3.2.2
- **Frontend**: Webpacker 5.2.1 + React 17
- **Issues**: Webpacker deprecated, mixed architecture, maintenance burden

### Target State
- **Rails**: 8.0
- **Ruby**: 3.3.0
- **Frontend**: Hotwire (Turbo + Stimulus) + Importmap
- **Mobile**: Turbo Native (iOS + Android)
- **Result**: One codebase, 95% code sharing, 75% less maintenance

### Timeline: 12 weeks (3 months)

| Phase | Duration | Focus |
|-------|----------|-------|
| Phase 1 | 4 weeks | Rails 8 upgrade |
| Phase 2 | 4 weeks | React → Stimulus conversion |
| Phase 3 | 2 weeks | Native apps setup |
| Phase 4 | 2 weeks | Testing & polish |

### Team
- **Backend Developer** (you): Rails, views, controllers, models, deployment
- **Frontend Developer**: Stimulus controllers, Strada bridges, styling

---

## Current State

### Tech Stack
```yaml
Framework: Rails 7.0.8
Ruby: 3.2.2
JavaScript Bundler: Webpacker 5.2.1 (deprecated ❌)
Frontend: React 17 + Redux
CSS: Foundation 6.4 + Sass
Database: PostgreSQL
Background Jobs: Sidekiq
Deployment: Kamal 2.3
```

### Existing React Components
```
app/javascript/src/
├── shopAdmin/           # Admin interface
├── shopClient/          # Customer shop interface
├── strava/              # Strava integration
├── fileUploader/        # File upload component
├── calendarIcon/        # Calendar widgets
└── narciarskieDziki/    # Custom feature
```

### Problems to Solve
1. ❌ Webpacker is deprecated and unmaintained
2. ❌ Complex build setup (Webpack + Babel + React)
3. ❌ High maintenance burden (two paradigms: React + Rails views)
4. ❌ No mobile app (need separate React Native if we want mobile)
5. ❌ Slow build times
6. ❌ React overkill for many simple features

---

## Target Architecture

### System Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Rails 8 Application                       │
│                                                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │          Web Interface (Hotwire)                   │     │
│  │                                                    │     │
│  │  ┌──────────────────────────────────────────┐    │     │
│  │  │  Turbo Drive                             │    │     │
│  │  │  - SPA-like navigation                   │    │     │
│  │  │  - No full page reloads                  │    │     │
│  │  └──────────────────────────────────────────┘    │     │
│  │                                                    │     │
│  │  ┌──────────────────────────────────────────┐    │     │
│  │  │  Turbo Frames                            │    │     │
│  │  │  - Independent page sections             │    │     │
│  │  │  - Lazy loading                          │    │     │
│  │  └──────────────────────────────────────────┘    │     │
│  │                                                    │     │
│  │  ┌──────────────────────────────────────────┐    │     │
│  │  │  Turbo Streams                           │    │     │
│  │  │  - Real-time updates                     │    │     │
│  │  │  - WebSocket support                     │    │     │
│  │  └──────────────────────────────────────────┘    │     │
│  │                                                    │     │
│  │  ┌──────────────────────────────────────────┐    │     │
│  │  │  Stimulus Controllers                    │    │     │
│  │  │  - JavaScript sprinkles                  │    │     │
│  │  │  - Event handling                        │    │     │
│  │  └──────────────────────────────────────────┘    │     │
│  └────────────────────────────────────────────────────┘     │
│                                                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │          API Endpoints (Optional)                  │     │
│  │  - JSON for complex native interactions           │     │
│  │  - Used by FE dev for custom components           │     │
│  └────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
                          ▲
                          │ HTTP requests (same HTML)
                          │
        ┌─────────────────┴───────────────────┐
        │                                     │
┌───────▼────────┐                  ┌─────────▼────────┐
│  iOS App       │                  │  Android App     │
│  (Turbo Native)│                  │  (Turbo Native)  │
│                │                  │                  │
│  + Strada      │                  │  + Strada        │
│  (for native   │                  │  (for native     │
│   features)    │                  │   features)      │
└────────────────┘                  └──────────────────┘
```

### File Structure

```
kw-app/
├── app/
│   ├── controllers/              # Rails controllers
│   │   ├── users_controller.rb
│   │   ├── events_controller.rb
│   │   ├── shop_controller.rb
│   │   └── api/                 # Optional API endpoints
│   │       └── v1/
│   │           └── products_controller.rb
│   │
│   ├── views/                   # Server-rendered views
│   │   ├── users/
│   │   │   ├── index.html.slim
│   │   │   └── show.html.slim
│   │   ├── shop/
│   │   │   ├── index.html.slim
│   │   │   ├── cart.html.slim
│   │   │   └── _cart_item.html.slim
│   │   └── layouts/
│   │       └── application.html.slim
│   │
│   ├── javascript/              # Frontend JavaScript
│   │   ├── application.js       # Entry point
│   │   │
│   │   ├── controllers/         # Stimulus controllers (FE dev works here)
│   │   │   ├── cart_controller.js
│   │   │   ├── search_controller.js
│   │   │   ├── calendar_controller.js
│   │   │   ├── shop_filter_controller.js
│   │   │   └── strava_sync_controller.js
│   │   │
│   │   └── bridges/             # Strada bridges (native features)
│   │       ├── menu_component.js
│   │       ├── camera_component.js
│   │       └── notification_component.js
│   │
│   ├── assets/
│   │   ├── stylesheets/
│   │   │   └── application.css
│   │   └── images/
│   │
│   └── models/                  # ActiveRecord models
│       ├── user.rb
│       └── event.rb
│
├── ios/                         # Turbo Native iOS app
│   └── KwApp/
│       ├── AppDelegate.swift
│       ├── SceneController.swift
│       └── Bridges/            # Native implementations
│           ├── CameraComponent.swift
│           └── MenuComponent.swift
│
├── android/                     # Turbo Native Android app
│   └── app/
│       └── src/
│           └── main/
│               └── kotlin/
│                   └── com/kwapp/
│                       ├── MainActivity.kt
│                       └── bridges/
│
└── config/
    └── importmap.rb            # JavaScript dependencies
```

---

## Why Hotwire + Turbo Native

### Benefits Comparison

| Metric | Current (React + Webpacker) | Hotwire + Turbo Native | Improvement |
|--------|----------------------------|------------------------|-------------|
| **Maintenance hours/month** | 40 hours | 10 hours | **75% reduction** |
| **Code sharing (web/mobile)** | 0% (no mobile) | 95% | **Native apps included** |
| **Build time** | 45 seconds | 0 seconds (dev) | **Instant** |
| **Feature development** | 5-7 days | 2-3 days | **2x faster** |
| **JavaScript complexity** | High (React, Redux, Webpack) | Low (Stimulus only) | **Much simpler** |
| **Learning curve** | 2-3 weeks | 2-3 days | **10x easier** |
| **Bundle size** | ~250kb | ~50kb | **80% smaller** |

### Key Advantages

✅ **Easy Maintenance**
- One codebase for web + iOS + Android
- Server-side rendering (less client-side complexity)
- No separate API to maintain
- Rails handles routing, auth, sessions

✅ **Developer Experience**
- FE developer works on pure JavaScript (Stimulus)
- No React/Redux/Webpack configuration
- Clear separation: Rails views vs JS controllers
- Fast feedback loop (no build step in dev)

✅ **Native Apps Included**
- Same HTML works in native apps
- Add native features via Strada (camera, GPS, etc.)
- One deploy updates all platforms
- No React Native learning curve

✅ **Performance**
- Faster initial page load (server-rendered)
- Smaller JavaScript bundles
- Efficient updates (Turbo Streams)
- Better for SEO

✅ **Future-Proof**
- Rails 8's official direction
- Used by: Basecamp (Hey.com), GitHub, Shopify
- Active development and community

---

## Migration Timeline

### 12-Week Plan

```
Week 1-2:  Preparation & Testing
Week 3-4:  Rails 8 Core Upgrade
Week 5-6:  Shop Components → Stimulus
Week 7-8:  Strava & Other Components → Stimulus
Week 9:    iOS App Setup
Week 10:   Android App Setup
Week 11:   Testing & Bug Fixes
Week 12:   Polish & Production Deploy
```

### Detailed Breakdown

#### Phase 1: Rails 8 Upgrade (Weeks 1-4)

**Week 1-2: Preparation**
- [ ] Full test suite passing
- [ ] Create Rails 8 branch
- [ ] Audit dependencies
- [ ] Update Ruby to 3.3.0
- [ ] Database backup strategy
- [ ] Team training (Hotwire basics)

**Week 3-4: Core Upgrade**
- [ ] Update Gemfile (Rails 8, Hotwire)
- [ ] Remove Webpacker
- [ ] Install Importmap, Turbo, Stimulus
- [ ] Run `bin/rails app:update`
- [ ] Fix deprecation warnings
- [ ] Update configuration files
- [ ] Basic smoke tests passing

**Deliverable**: Rails 8 running, Hotwire installed ✅

#### Phase 2: Frontend Conversion (Weeks 5-8)

**Week 5-6: Shop Components**
- [ ] Convert shop cart to Stimulus
- [ ] Convert product filters to Stimulus
- [ ] Convert search to Stimulus
- [ ] Add Turbo Frames for cart updates
- [ ] Test checkout flow

**Week 7-8: Other Components**
- [ ] Convert Strava sync to Stimulus
- [ ] Convert calendar components
- [ ] Convert file uploader
- [ ] Remove React dependencies
- [ ] Update tests

**Deliverable**: All React removed, Stimulus working ✅

#### Phase 3: Native Apps (Weeks 9-10)

**Week 9: iOS App**
- [ ] Create Xcode project
- [ ] Install Turbo via CocoaPods
- [ ] Basic app navigation
- [ ] Test authentication
- [ ] Add app icons/splash screen

**Week 10: Android App**
- [ ] Create Android Studio project
- [ ] Install Turbo library
- [ ] Basic app navigation
- [ ] Test authentication
- [ ] Add app icons/splash screen

**Deliverable**: iOS & Android apps running ✅

#### Phase 4: Testing & Launch (Weeks 11-12)

**Week 11: Testing**
- [ ] Full regression testing
- [ ] Performance testing
- [ ] Mobile app testing (iOS/Android)
- [ ] Bug fixes
- [ ] Load testing

**Week 12: Launch**
- [ ] Staging deployment
- [ ] Documentation
- [ ] Production deployment
- [ ] App Store submissions
- [ ] Team training
- [ ] Monitor & iterate

**Deliverable**: Production launch ✅

---

## Detailed Migration Steps

### Step 1: Prepare Environment

```bash
# 1. Create migration branch
git checkout -b rails-8-hotwire-migration

# 2. Update Ruby
echo "3.3.0" > .ruby-version
rbenv install 3.3.0
rbenv local 3.3.0

# 3. Verify Ruby version
ruby -v  # Should show 3.3.0
```

### Step 2: Update Gemfile

```ruby
# Gemfile
source 'https://rubygems.org'
ruby '3.3.0'

# Core Rails
gem 'rails', '~> 8.0'
gem 'bootsnap', require: false
gem 'pg', '~> 1.1'
gem 'puma'

# Hotwire stack
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'importmap-rails'

# Rails 8 performance
gem 'thruster', require: false, group: [:development, :production]

# Keep existing gems
gem 'devise', '~> 4.8.1'
gem 'sidekiq'
gem 'pagy'
gem 'ransack', '2.5.0'
gem 'searchkick'
gem 'carrierwave', '~> 3.1.2'
gem 'pundit' # or cancancan
gem 'paper_trail'
gem 'slim-rails'
gem 'kamal', '~> 2.3', require: false, group: [:tools]

# Keep dry-rb gems
gem 'dry-monads', '~> 1.3'
gem 'dry-validation', '~> 1.0'
gem 'dry-types'

# Remove these (Webpacker and React)
# gem '@rails/webpacker' # DELETE
# gem 'react-rails' # DELETE if present

group :development, :test do
  gem 'rspec-rails'
  gem 'byebug'
  gem 'factory_bot_rails'
end

group :development do
  gem 'listen'
  gem 'annotate'
end
```

### Step 3: Install Hotwire

```bash
# Install gems
bundle install

# Install Hotwire
rails turbo:install
rails stimulus:install
rails importmap:install

# This creates:
# - app/javascript/application.js
# - app/javascript/controllers/
# - config/importmap.rb
```

### Step 4: Update Application Layout

```slim
/ app/views/layouts/application.html.slim
doctype html
html lang="en"
  head
    meta charset="utf-8"
    meta name="viewport" content="width=device-width, initial-scale=1.0"
    
    title = content_for?(:title) ? yield(:title) : "KW App"
    
    / Rails 8 asset helpers
    = csrf_meta_tags
    = csp_meta_tag
    
    / Hotwire
    = javascript_importmap_tags
    = stylesheet_link_tag "application", "data-turbo-track": "reload"
    
  body
    = render 'layouts/flash_messages'
    = render 'layouts/navigation'
    
    main
      = yield
    
    = render 'layouts/footer'
```

### Step 5: Configure Importmap

```ruby
# config/importmap.rb
pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

# Pin all Stimulus controllers
pin_all_from "app/javascript/controllers", under: "controllers"

# Add any other JS libraries you need
pin "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"
```

### Step 6: Create Application JavaScript

```javascript
// app/javascript/application.js
import "@hotwired/turbo-rails"
import "./controllers"

// Configure Turbo
Turbo.session.drive = true

// Optional: Global configuration
console.log("Hotwire loaded!")
```

### Step 7: Setup Stimulus

```javascript
// app/javascript/controllers/application.js
import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

export { application }
```

```javascript
// app/javascript/controllers/index.js
import { application } from "./application"

// Import and register all your controllers
import HelloController from "./hello_controller"
application.register("hello", HelloController)

// Auto-load controllers from this directory
// import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
// eagerLoadControllersFrom("controllers", application)
```

### Step 8: Remove Webpacker

```bash
# Remove Webpacker files
rm -rf config/webpacker.yml
rm -rf config/webpack
rm -rf babel.config.js
rm -rf postcss.config.js

# Remove node_modules (we'll reinstall minimal deps)
rm -rf node_modules
rm -rf yarn.lock

# Update package.json
```

```json
{
  "name": "kw-app",
  "private": true,
  "dependencies": {
    "@hotwired/stimulus": "^3.2.2",
    "@hotwired/turbo-rails": "^8.0.4"
  },
  "scripts": {
    "build": "echo 'No build needed with importmap!'"
  }
}
```

```bash
# Install minimal dependencies
yarn install
```

---

## Code Examples & Conversions

### Example 1: Shop Cart Component

#### Before (React + Redux)

```javascript
// app/javascript/src/shopClient/Cart.jsx
import React, { useState, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { addToCart, removeFromCart, fetchCart } from './cartSlice';

export default function Cart() {
  const dispatch = useDispatch();
  const items = useSelector(state => state.cart.items);
  const total = useSelector(state => state.cart.total);
  
  useEffect(() => {
    dispatch(fetchCart());
  }, []);
  
  const handleAddToCart = (productId) => {
    dispatch(addToCart(productId));
  };
  
  const handleRemoveFromCart = (itemId) => {
    dispatch(removeFromCart(itemId));
  };
  
  return (
    <div className="cart">
      <h2>Shopping Cart ({items.length})</h2>
      {items.map(item => (
        <div key={item.id} className="cart-item">
          <span>{item.name}</span>
          <span>${item.price}</span>
          <button onClick={() => handleRemoveFromCart(item.id)}>
            Remove
          </button>
        </div>
      ))}
      <div className="cart-total">
        Total: ${total}
      </div>
    </div>
  );
}
```

#### After (Stimulus)

```javascript
// app/javascript/controllers/cart_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["count", "total", "items"]
  static values = { 
    url: String,
    productId: Number 
  }
  
  connect() {
    console.log("Cart controller connected")
  }
  
  async addToCart(event) {
    event.preventDefault()
    
    const productId = event.params.productId
    
    const response = await fetch('/shop/cart/add', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': this.csrfToken
      },
      body: JSON.stringify({ product_id: productId })
    })
    
    if (response.ok) {
      const html = await response.text()
      this.itemsTarget.innerHTML = html
      this.updateCount()
    }
  }
  
  async removeFromCart(event) {
    event.preventDefault()
    
    const itemId = event.params.itemId
    
    const response = await fetch(`/shop/cart/remove/${itemId}`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': this.csrfToken
      }
    })
    
    if (response.ok) {
      const html = await response.text()
      this.itemsTarget.innerHTML = html
      this.updateCount()
    }
  }
  
  updateCount() {
    const count = this.itemsTarget.querySelectorAll('.cart-item').length
    this.countTarget.textContent = count
  }
  
  get csrfToken() {
    return document.querySelector('[name="csrf-token"]').content
  }
}
```

**Rails View:**

```slim
/ app/views/shop/cart.html.slim
div(
  data-controller="cart"
  data-cart-url-value="<%= shop_cart_path %>"
)
  h2
    | Shopping Cart 
    span(data-cart-target="count") = @cart.items.count
  
  div(data-cart-target="items")
    = render partial: "shop/cart_items", locals: { items: @cart.items }
  
  div.cart-total(data-cart-target="total")
    | Total: 
    = number_to_currency(@cart.total)
```

**Cart Items Partial:**

```slim
/ app/views/shop/_cart_items.html.slim
- items.each do |item|
  div.cart-item
    span = item.name
    span = number_to_currency(item.price)
    button(
      data-action="click->cart#removeFromCart"
      data-cart-item-id-param="<%= item.id %>"
    ) Remove
```

**Rails Controller:**

```ruby
# app/controllers/shop/carts_controller.rb
class Shop::CartsController < ApplicationController
  def show
    @cart = current_user.cart
  end
  
  def add
    @cart = current_user.cart
    @cart.add_item(params[:product_id])
    
    respond_to do |format|
      format.turbo_stream
      format.html { render partial: "cart_items", locals: { items: @cart.items } }
    end
  end
  
  def remove
    @cart = current_user.cart
    @cart.remove_item(params[:id])
    
    render partial: "cart_items", locals: { items: @cart.items }
  end
end
```

**Benefits:**
- ✅ 50% less code
- ✅ No Redux complexity
- ✅ Server handles state
- ✅ Easier to test
- ✅ Works in native apps automatically

---

### Example 2: Live Search with Turbo Frames

#### Before (React)

```javascript
// app/javascript/src/Search.jsx
import React, { useState, useEffect } from 'react';
import axios from 'axios';

export default function Search() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);
  
  useEffect(() => {
    const timer = setTimeout(() => {
      if (query.length > 2) {
        performSearch();
      }
    }, 300);
    
    return () => clearTimeout(timer);
  }, [query]);
  
  const performSearch = async () => {
    setLoading(true);
    try {
      const response = await axios.get('/api/search', {
        params: { q: query }
      });
      setResults(response.data);
    } finally {
      setLoading(false);
    }
  };
  
  return (
    <div>
      <input 
        type="text"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Search..."
      />
      {loading && <div>Loading...</div>}
      <div className="results">
        {results.map(result => (
          <div key={result.id}>{result.name}</div>
        ))}
      </div>
    </div>
  );
}
```

#### After (Stimulus + Turbo Frame)

```javascript
// app/javascript/controllers/search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]
  static values = { url: String }
  
  search() {
    clearTimeout(this.timeout)
    
    this.timeout = setTimeout(() => {
      this.performSearch()
    }, 300)
  }
  
  async performSearch() {
    const query = this.inputTarget.value
    
    if (query.length < 3) {
      this.resultsTarget.innerHTML = ''
      return
    }
    
    const url = `${this.urlValue}?q=${encodeURIComponent(query)}`
    
    try {
      const response = await fetch(url, {
        headers: { 'Accept': 'text/html' }
      })
      
      const html = await response.text()
      this.resultsTarget.innerHTML = html
    } catch (error) {
      console.error('Search failed:', error)
    }
  }
}
```

**Even Better: Pure Turbo Frame (No JavaScript Needed!)**

```slim
/ app/views/search/index.html.slim
= form_with url: search_path, method: :get, data: { turbo_frame: "search_results" } do |f|
  = f.text_field :q, 
    placeholder: "Search...",
    data: { 
      controller: "search",
      action: "input->search#search",
      search_target: "input"
    }

turbo-frame#search_results
  / Results load here automatically
```

**Rails Controller:**

```ruby
# app/controllers/search_controller.rb
class SearchController < ApplicationController
  def index
    @results = Event.search(params[:q]) if params[:q].present?
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
```

**Results Partial:**

```slim
/ app/views/search/_results.html.slim
- results.each do |result|
  div.search-result
    = link_to result.name, result
    p = result.description.truncate(100)
```

---

### Example 3: Real-time Updates with Turbo Streams

#### Before (React + WebSockets)

```javascript
// Complex React + Redux + Action Cable setup
// Multiple files needed...
```

#### After (Turbo Streams)

**Rails View:**

```slim
/ app/views/events/show.html.slim
= turbo_stream_from @event

h1 = @event.name

div#event-participants
  = render partial: "participants", locals: { participants: @event.participants }
```

**Rails Model:**

```ruby
# app/models/event.rb
class Event < ApplicationRecord
  has_many :participants
  
  after_update_commit -> { broadcast_replace_to self }
end
```

**Rails Controller:**

```ruby
# app/controllers/participants_controller.rb
class ParticipantsController < ApplicationController
  def create
    @event = Event.find(params[:event_id])
    @participant = @event.participants.create(participant_params)
    
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          "event-participants",
          partial: "events/participant",
          locals: { participant: @participant }
        )
      end
      format.html { redirect_to @event }
    end
  end
end
```

**That's it!** Real-time updates work automatically. When someone joins, all connected users see the update instantly.

---

## Division of Work

### Backend Developer (You) - 70% of work

**Responsibilities:**

✅ **Rails Infrastructure**
- Controllers (business logic, routing)
- Models (database, validations, associations)
- Database migrations
- Background jobs (Sidekiq)
- Authentication & authorization (Devise, Pundit)
- API endpoints (if needed)

✅ **Views**
- HTML structure (Slim templates)
- Turbo Frame placement
- Turbo Stream responses
- Partials for reusable components

✅ **Configuration**
- Rails config files
- Routes
- Importmap configuration
- Environment variables
- Deployment (Kamal)

✅ **Testing**
- Model tests
- Controller tests
- Integration tests
- System tests (full features)

**Example Daily Tasks:**
```ruby
# Create new feature
rails g scaffold Event name:string date:datetime location:string

# Add Turbo behavior to views
# app/views/events/index.html.slim
turbo-frame#events
  = render @events

# Controller handles both HTML and Turbo
def create
  @event = Event.new(event_params)
  
  respond_to do |format|
    if @event.save
      format.turbo_stream
      format.html { redirect_to @event }
    else
      format.html { render :new }
    end
  end
end
```

### Frontend Developer - 30% of work

**Responsibilities:**

✅ **Stimulus Controllers**
- Interactive JavaScript components
- Form validations
- Dynamic UI updates
- API consumption (when needed)

✅ **Strada Bridges** (for native features)
- Camera access
- Geolocation
- Push notifications
- Native menus

✅ **Styling**
- CSS/SCSS
- Component styling
- Responsive design
- Animations

✅ **JavaScript Testing**
- Stimulus controller tests
- Integration with Rails system tests

**Example Daily Tasks:**
```javascript
// Create interactive component
// app/javascript/controllers/dropdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  
  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }
  
  close(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }
}
```

**Key Point:** FE developer doesn't need to touch Ruby/Rails code!

---

## Frontend Developer Onboarding

### Welcome! 👋

You'll be working primarily with **Stimulus** - a lightweight JavaScript framework that's easy to learn.

### What You Need to Know

#### 1. Your Working Directory

```
app/javascript/
├── application.js        # Main entry (you rarely touch this)
├── controllers/          # THIS IS WHERE YOU WORK!
│   ├── cart_controller.js
│   ├── search_controller.js
│   └── dropdown_controller.js
└── bridges/             # For native features
    └── camera_component.js
```

#### 2. Stimulus Basics (Learn in 1 Hour)

**Concept:** Connect JavaScript behavior to HTML elements using `data-` attributes.

**Three Main Concepts:**

1. **Controllers** - JavaScript classes that add behavior
2. **Targets** - Elements you want to reference
3. **Actions** - Events that trigger methods

**Example:**

```html
<!-- HTML (written by backend dev) -->
<div data-controller="counter">
  <button data-action="click->counter#increment">+</button>
  <span data-counter-target="count">0</span>
</div>
```

```javascript
// JavaScript (you write this)
// app/javascript/controllers/counter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["count"]
  
  increment() {
    const currentValue = parseInt(this.countTarget.textContent)
    this.countTarget.textContent = currentValue + 1
  }
}
```

**That's it!** No complex setup, no JSX, no build config.

#### 3. Common Patterns You'll Use

**Pattern 1: Fetch Data**

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  async loadData() {
    const response = await fetch('/api/data')
    const data = await response.json()
    this.updateUI(data)
  }
  
  updateUI(data) {
    // Update DOM with data
  }
}
```

**Pattern 2: Form Submission**

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  async submit(event) {
    event.preventDefault()
    
    const formData = new FormData(event.target)
    
    const response = await fetch(event.target.action, {
      method: 'POST',
      body: formData,
      headers: {
        'X-CSRF-Token': this.csrfToken
      }
    })
    
    if (response.ok) {
      // Success handling
    }
  }
  
  get csrfToken() {
    return document.querySelector('[name="csrf-token"]').content
  }
}
```

**Pattern 3: Real-time Updates**

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Turbo handles this automatically!
    // You rarely need to write WebSocket code
  }
}
```

#### 4. Your Daily Workflow

**Step 1: Backend dev creates feature request**
```
"Add live search to events page"
```

**Step 2: Backend dev provides:**
- HTML structure with data attributes
- API endpoint or Turbo Frame URL
- Expected behavior

**Step 3: You create Stimulus controller:**

```javascript
// app/javascript/controllers/events_search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]
  
  search() {
    // Your implementation
  }
}
```

**Step 4: Test in browser**
```bash
# No build step needed!
# Just refresh the page
```

**Step 5: Commit and done!**

#### 5. Tools & Resources

**Editor Setup:**
- VS Code with "Stimulus LSP" extension
- "Stimulus Autocomplete" extension

**Learning Resources:**
- Stimulus Handbook: https://stimulus.hotwired.dev/handbook/introduction
- Stimulus Examples: https://stimulus.hotwired.dev/reference/controllers
- Video: "Stimulus 101" (30 minutes on YouTube)

**Debugging:**
```javascript
// Add debug logging
export default class extends Controller {
  connect() {
    console.log("Controller connected", this.element)
    console.log("Available targets:", this.targets)
  }
}
```

**Testing:**
```javascript
// test/javascript/controllers/cart_controller_test.js
import { Application } from "@hotwired/stimulus"
import CartController from "../../app/javascript/controllers/cart_controller"

describe("CartController", () => {
  let application
  
  beforeEach(() => {
    application = Application.start()
    application.register("cart", CartController)
  })
  
  it("adds item to cart", async () => {
    // Your tests
  })
})
```

#### 6. When You Need Help

**Questions Backend Dev Can Answer:**
- "What endpoint should I call?"
- "What data format will I receive?"
- "Where should this feature go?"

**Questions You Own:**
- "How do I implement this interaction?"
- "What's the best way to structure this controller?"
- "Should I split this into multiple controllers?"

**Resources:**
- Stimulus Discourse: https://discuss.hotwired.dev/
- Rails Hotwire Slack: https://hotwired.dev/

#### 7. Native App Development (Optional)

If working on iOS/Android apps:

**Strada Bridges** - Connect web components to native features

```javascript
// app/javascript/bridges/camera_component.js
import { BridgeComponent } from "@hotwired/strada"

export default class extends BridgeComponent {
  static component = "camera"
  
  openCamera() {
    // Send message to native app
    this.send("openCamera", {}, (message) => {
      // Receive photo from native
      const photoURL = message.data.url
      this.updatePhoto(photoURL)
    })
  }
}
```

**Native Swift (iOS):**
```swift
// ios/KwApp/Bridges/CameraComponent.swift
import Strada

final class CameraComponent: BridgeComponent {
    override class var name: String { "camera" }
    
    override func onReceive(message: Message) {
        guard message.event == "openCamera" else { return }
        
        // Open native camera
        let picker = UIImagePickerController()
        // ... implementation
    }
}
```

**Don't worry!** This is only needed for native features. Web app works without it.

---

### Your First Task: Hello World

**Create your first Stimulus controller:**

```javascript
// app/javascript/controllers/hello_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "output"]
  
  greet() {
    const name = this.nameTarget.value
    this.outputTarget.textContent = `Hello, ${name}!`
  }
}
```

**Backend dev will create this view:**
```slim
div(data-controller="hello")
  input(
    type="text"
    data-hello-target="name"
    placeholder="Your name"
  )
  button(data-action="click->hello#greet") Say Hello
  div(data-hello-target="output")
```

**Test it!** Open the page, type your name, click button. It works! 🎉

### Requirements & Expectations

**Must Have Skills:**
- ✅ JavaScript (ES6+)
- ✅ DOM manipulation
- ✅ Fetch API / AJAX
- ✅ CSS/SCSS

**Nice to Have:**
- ⭐ TypeScript (optional)
- ⭐ Git workflow
- ⭐ Browser DevTools
- ⭐ Swift/Kotlin basics (for native apps)

**You Don't Need:**
- ❌ Ruby/Rails knowledge (backend dev handles this)
- ❌ React/Vue experience (Stimulus is different)
- ❌ Webpack/build tool configuration
- ❌ State management (Redux, etc.)

**Workflow Expectations:**

1. **Communication:** Daily standups, clear requirements
2. **Code Quality:** ESLint, clean code, comments
3. **Testing:** Write tests for complex controllers
4. **Documentation:** Document tricky interactions
5. **Independence:** You own JavaScript, backend dev owns Rails

**Estimated Learning Time:**
- Day 1: Stimulus basics (4 hours)
- Day 2-3: Build first feature (8 hours)
- Week 1: Comfortable with workflow
- Week 2-4: Fully productive

---

## Development Workflow

### Daily Development Process

#### 1. Backend Developer (Morning)

```bash
# Start working on feature
git checkout -b feature/event-registration

# Create models and migrations
rails g model Registration event:references user:references status:string

# Migrate database
rails db:migrate

# Create controllers and views
rails g controller Registrations create destroy

# Write business logic
# app/controllers/registrations_controller.rb

# Create views with Stimulus hooks
# app/views/events/show.html.slim
```

**View Template:**
```slim
div(
  data-controller="registration"
  data-registration-event-id-value="<%= @event.id %>"
)
  h2 = @event.name
  
  button(
    data-action="click->registration#register"
    class="btn btn-primary"
  ) Register for Event
  
  div(data-registration-target="status")
```

**Commit and notify FE developer:**
```bash
git add .
git commit -m "Add registration feature (needs JS)"
git push

# Slack message:
"@fe-dev I've pushed the registration feature.
 - Controller: `registration_controller.js` needed
 - API endpoint: POST /events/:id/register
 - See views/events/show.html.slim for data attributes"
```

#### 2. Frontend Developer (Afternoon)

```javascript
// app/javascript/controllers/registration_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["status"]
  static values = { eventId: Number }
  
  async register(event) {
    event.preventDefault()
    
    try {
      const response = await fetch(`/events/${this.eventIdValue}/register`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': this.csrfToken,
          'Content-Type': 'application/json'
        }
      })
      
      if (response.ok) {
        this.statusTarget.innerHTML = `
          <div class="alert alert-success">
            ✓ Registered successfully!
          </div>
        `
        event.target.disabled = true
      } else {
        throw new Error('Registration failed')
      }
    } catch (error) {
      this.statusTarget.innerHTML = `
        <div class="alert alert-danger">
          ✗ ${error.message}
        </div>
      `
    }
  }
  
  get csrfToken() {
    return document.querySelector('[name="csrf-token"]').content
  }
}
```

**Test and commit:**
```bash
# Test in browser
open http://localhost:3000/events/1

# Add tests
# test/javascript/controllers/registration_controller_test.js

git add app/javascript/controllers/registration_controller.js
git commit -m "Add registration controller"
git push
```

#### 3. Code Review & Merge

```bash
# Create pull request
gh pr create --title "Feature: Event Registration" --body "Closes #123"

# Review
# - Backend dev reviews Rails code
# - FE dev reviews JS code
# - Both test together

# Merge
git checkout main
git merge feature/event-registration
```

### Running the Application

**Development Mode:**

```bash
# Option 1: Simple (one terminal)
bin/rails server

# Option 2: With Procfile (auto-reload CSS)
bin/dev
```

**Procfile.dev:**
```yaml
web: bin/rails server -p 3000
css: bin/rails tailwindcss:watch
```

**Testing:**

```bash
# Backend tests
bin/rails test
bin/rails test:system

# Frontend tests (if using)
npm test

# Run specific test
bin/rails test test/controllers/events_controller_test.rb
```

**Debugging:**

```ruby
# Backend (Ruby)
debugger  # or 'binding.pry' with pry gem

# Frontend (JavaScript)
console.log("Debug:", this.element)
debugger  # Browser DevTools will pause here
```

### Git Workflow

**Branch Naming:**
```
feature/event-registration
bugfix/cart-total-calculation
refactor/stimulus-controllers
```

**Commit Messages:**
```
feat: add event registration feature
fix: correct cart total calculation
refactor: split large controller into smaller ones
test: add tests for registration controller
docs: update README with Stimulus info
```

**Pull Request Template:**

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Refactoring
- [ ] Documentation

## Testing
- [ ] Unit tests pass
- [ ] System tests pass
- [ ] Manual testing completed

## Screenshots (if UI changes)
[attach screenshots]

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
```

---

## Testing Strategy

### Backend Tests (RSpec)

```ruby
# spec/models/event_spec.rb
RSpec.describe Event, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:date) }
  end
  
  describe "associations" do
    it { should have_many(:registrations) }
    it { should have_many(:participants).through(:registrations) }
  end
end

# spec/controllers/registrations_controller_spec.rb
RSpec.describe RegistrationsController, type: :controller do
  describe "POST #create" do
    let(:event) { create(:event) }
    let(:user) { create(:user) }
    
    before { sign_in user }
    
    it "creates a registration" do
      expect {
        post :create, params: { event_id: event.id }
      }.to change(Registration, :count).by(1)
    end
    
    it "returns success response" do
      post :create, params: { event_id: event.id }
      expect(response).to have_http_status(:success)
    end
  end
end

# spec/system/event_registration_spec.rb
RSpec.describe "Event Registration", type: :system do
  let(:event) { create(:event) }
  let(:user) { create(:user) }
  
  before do
    sign_in user
    visit event_path(event)
  end
  
  it "allows user to register for event" do
    click_button "Register for Event"
    
    expect(page).to have_content("Registered successfully")
    expect(event.participants).to include(user)
  end
  
  it "disables button after registration" do
    click_button "Register for Event"
    
    expect(page).to have_button("Register for Event", disabled: true)
  end
end
```

### Frontend Tests (JavaScript)

```javascript
// test/javascript/controllers/registration_controller_test.js
import { Application } from "@hotwired/stimulus"
import { expect } from "chai"
import RegistrationController from "controllers/registration_controller"

describe("RegistrationController", () => {
  let application, element
  
  beforeEach(() => {
    application = Application.start()
    application.register("registration", RegistrationController)
    
    element = document.createElement("div")
    element.dataset.controller = "registration"
    element.dataset.registrationEventIdValue = "1"
    element.innerHTML = `
      <button data-action="click->registration#register">Register</button>
      <div data-registration-target="status"></div>
    `
    document.body.appendChild(element)
  })
  
  afterEach(() => {
    document.body.removeChild(element)
    application.stop()
  })
  
  it("shows success message on successful registration", async () => {
    global.fetch = () => Promise.resolve({ ok: true })
    
    const button = element.querySelector("button")
    button.click()
    
    await new Promise(resolve => setTimeout(resolve, 100))
    
    const status = element.querySelector("[data-registration-target='status']")
    expect(status.textContent).to.include("Registered successfully")
  })
  
  it("disables button after registration", async () => {
    global.fetch = () => Promise.resolve({ ok: true })
    
    const button = element.querySelector("button")
    button.click()
    
    await new Promise(resolve => setTimeout(resolve, 100))
    
    expect(button.disabled).to.be.true
  })
})
```

### Testing Checklist

**Before Every Commit:**
- [ ] Run tests: `bin/rails test`
- [ ] Check for linting errors: `rubocop`
- [ ] Verify system tests pass: `bin/rails test:system`

**Before Every Pull Request:**
- [ ] All tests passing
- [ ] New features have tests
- [ ] Manual testing completed
- [ ] No console errors in browser
- [ ] Works in mobile view

**Before Production Deploy:**
- [ ] Full regression testing
- [ ] Performance testing
- [ ] Security audit
- [ ] Staging deployment successful
- [ ] Rollback plan ready

---

## Deployment

### Staging Deployment (Kamal)

```bash
# Kamal is already configured!

# Deploy to staging
kamal deploy -d staging

# Check status
kamal app logs -d staging

# SSH into server
kamal app exec -i -d staging bash
```

### Production Deployment

```bash
# 1. Tag release
git tag -a v1.0.0 -m "Rails 8 + Hotwire migration complete"
git push origin v1.0.0

# 2. Deploy
kamal deploy

# 3. Monitor
kamal app logs -f

# 4. Verify
curl https://yourdomain.com/up
# Should return: "OK"

# 5. Rollback if needed
kamal rollback
```

### Mobile App Deployment

#### iOS (App Store)

```bash
cd ios

# 1. Update version
# Open KwApp.xcodeproj in Xcode
# Increment version number

# 2. Archive
xcodebuild archive \
  -scheme KwApp \
  -archivePath build/KwApp.xcarchive

# 3. Export
xcodebuild -exportArchive \
  -archivePath build/KwApp.xcarchive \
  -exportPath build \
  -exportOptionsPlist ExportOptions.plist

# 4. Upload to App Store Connect
# Use Transporter app or:
xcrun altool --upload-app \
  --type ios \
  --file build/KwApp.ipa \
  --username "your-email@example.com" \
  --password "@keychain:AC_PASSWORD"

# Or use Fastlane (recommended)
fastlane release
```

#### Android (Play Store)

```bash
cd android

# 1. Update version
# Edit app/build.gradle
# Increment versionCode and versionName

# 2. Build release bundle
./gradlew bundleRelease

# 3. Sign bundle
jarsigner -verbose \
  -sigalg SHA256withRSA \
  -digestalg SHA-256 \
  -keystore your-keystore.jks \
  app/build/outputs/bundle/release/app-release.aab

# 4. Upload to Play Console
# Use Google Play Console UI or:
fastlane release
```

### Continuous Deployment

**GitHub Actions Workflow:**

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.3.0
          bundler-cache: true
      - run: bin/rails test
      - run: bin/rails test:system
  
  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - name: Deploy with Kamal
        env:
          KAMAL_REGISTRY_PASSWORD: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
        run: |
          gem install kamal
          kamal deploy
```

---

## Success Metrics

### Technical Metrics

**Before Migration (Current):**
- Build time: 45 seconds
- Bundle size: 250kb
- Time to interactive: 3.5 seconds
- Lighthouse score: 65/100
- Test suite runtime: 8 minutes
- Deploy time: 10 minutes

**After Migration (Target):**
- Build time: 0 seconds (dev)
- Bundle size: 50kb (-80%)
- Time to interactive: 1.5 seconds (-57%)
- Lighthouse score: 90+/100
- Test suite runtime: 5 minutes (-37%)
- Deploy time: 8 minutes

### Development Metrics

**Feature Development Time:**
- Before: 5-7 days per feature
- After: 2-3 days per feature
- Improvement: **2x faster**

**Maintenance Time:**
- Before: 40 hours/month
- After: 10 hours/month
- Improvement: **75% reduction**

**Onboarding Time:**
- React + Redux: 2-3 weeks
- Stimulus: 2-3 days
- Improvement: **10x faster**

### Business Metrics

**Code Sharing:**
- Before: 0% (no mobile app)
- After: 95% (web + iOS + Android)
- Result: **Native apps at minimal cost**

**Team Efficiency:**
- Before: 1 Rails dev
- After: 1 Rails dev + 1 JS dev (working simultaneously)
- Result: **2x development capacity**

**Platform Coverage:**
- Before: Web only
- After: Web + iOS + Android
- Result: **3x platform coverage**

---

## Final Checklist

### Pre-Migration
- [ ] Stakeholder buy-in
- [ ] Team training scheduled
- [ ] Timeline approved
- [ ] Budget allocated
- [ ] Rollback plan documented

### Phase 1: Rails 8 Upgrade
- [ ] Ruby 3.3.0 installed
- [ ] Rails 8.0 installed
- [ ] Hotwire installed (Turbo, Stimulus, Importmap)
- [ ] Webpacker removed
- [ ] Tests passing
- [ ] Development environment working

### Phase 2: Frontend Conversion
- [ ] Shop components converted
- [ ] Strava components converted
- [ ] Calendar components converted
- [ ] File uploader converted
- [ ] React dependencies removed
- [ ] All features tested

### Phase 3: Native Apps
- [ ] iOS app created and tested
- [ ] Android app created and tested
- [ ] Authentication working in apps
- [ ] Strada bridges implemented (if needed)
- [ ] App icons and splash screens

### Phase 4: Launch
- [ ] Staging deployment successful
- [ ] Production deployment successful
- [ ] iOS app submitted to App Store
- [ ] Android app submitted to Play Store
- [ ] Documentation complete
- [ ] Team trained
- [ ] Monitoring in place

---

## Support & Resources

### Documentation
- Rails 8 Guides: https://guides.rubyonrails.org/
- Hotwire: https://hotwired.dev/
- Turbo: https://turbo.hotwired.dev/
- Stimulus: https://stimulus.hotwired.dev/
- Turbo Native iOS: https://github.com/hotwired/turbo-ios
- Turbo Native Android: https://github.com/hotwired/turbo-android

### Community
- Hotwire Discussion: https://discuss.hotwired.dev/
- Rails Discord: https://discord.gg/d35t4vr
- Stimulus Patterns: https://www.stimulus-components.com/

### Learning
- GoRails Hotwire Course: https://gorails.com/series/hotwire-rails
- Pragmatic Studio Hotwire Course: https://pragmaticstudio.com/hotwire
- Hotwire Handbook: https://hotwirehandbook.com/

### Tools
- Stimulus LSP (VS Code extension)
- Turbo DevTools (browser extension)
- Rails Performance APM

---

## Questions?

**For Backend Developer:**
- Technical architecture decisions
- Database schema design
- Rails best practices
- Deployment strategy

**For Frontend Developer:**
- Stimulus patterns
- JavaScript implementation
- Styling and CSS
- Browser compatibility

**For Both:**
- Feature requirements
- Timeline adjustments
- Priority changes
- Team coordination

---

## Let's Build! 🚀

**Next Actions:**

1. **This Week:**
   - [ ] Review this document
   - [ ] Schedule team meeting
   - [ ] Show FE developer Stimulus basics
   - [ ] Create test branch

2. **Next Week:**
   - [ ] Start Rails 8 upgrade
   - [ ] Convert one component as proof of concept
   - [ ] Decide: proceed or adjust?

3. **Month 1:**
   - [ ] Complete Rails 8 upgrade
   - [ ] Begin React → Stimulus conversion

**Timeline**: 12 weeks to full migration with native apps
**Outcome**: 75% less maintenance, native apps included, 2x faster development

Ready to start? Let's do this! 💪