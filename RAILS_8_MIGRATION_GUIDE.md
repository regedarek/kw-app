# Rails 8 + Hotwire Native: Complete Migration Guide

**Strategy**: Delete React, rebuild with Stimulus, keep existing Rails views

**Goals**:
1. Maximum easy maintenance
2. Enable JS developer to work independently
3. Build native iOS/Android apps from same codebase
4. 95% code sharing between web and mobile

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Current State Analysis](#current-state-analysis)
3. [Target Architecture](#target-architecture)
4. [Migration Strategy](#migration-strategy)
5. [Why This Approach](#why-this-approach)
6. [Timeline](#timeline)
7. [Step-by-Step Migration](#step-by-step-migration)
8. [Code Examples](#code-examples)
9. [Team Structure](#team-structure)
10. [Frontend Developer Guide](#frontend-developer-guide)
11. [Development Workflow](#development-workflow)
12. [Testing](#testing)
13. [Deployment](#deployment)
14. [Success Metrics](#success-metrics)

---

## Executive Summary

### Current State
- **Rails**: 7.0.8
- **Ruby**: 3.2.2
- **Frontend**: Webpacker 5.2.1 (deprecated) + React 17
- **Problem**: Maintenance burden, no mobile apps, complex build

### Target State
- **Rails**: 8.0
- **Ruby**: 3.3.0
- **Frontend**: Hotwire (Turbo + Stimulus) + Importmap
- **Mobile**: Turbo Native (iOS + Android)
- **Result**: 75% less maintenance, native apps included, 2x faster development

### What We'll Do

```
1. Delete React Features Completely
   ├─ Shop components → DELETE
   ├─ Strava components → DELETE
   ├─ Calendar widgets → DELETE
   └─ File uploader → DELETE

2. Keep Existing Rails Views
   ├─ Admin panels → KEEP (already work!)
   ├─ User management → KEEP
   ├─ CRUD pages → KEEP
   └─ Forms → KEEP

3. Rebuild React Features with Stimulus
   ├─ Shop → Build fresh with Stimulus
   ├─ Strava → Build fresh with Stimulus
   ├─ Calendar → Build fresh with Stimulus
   └─ File uploader → Build fresh with Stimulus

4. Launch Native Apps
   ├─ iOS → Turbo Native
   └─ Android → Turbo Native
```

### Timeline: 10 Weeks

| Phase | Duration | What Happens |
|-------|----------|--------------|
| Phase 1 | 2 weeks | Rails 8 upgrade, remove Webpacker/React |
| Phase 2 | 4 weeks | Rebuild features with Stimulus |
| Phase 3 | 2 weeks | Native apps setup |
| Phase 4 | 2 weeks | Testing & launch |

---

## Current State Analysis

### Your App Today

```
kw-app/
├── React Components (via Webpacker)    ❌ DELETE THESE
│   ├── app/javascript/src/shopAdmin/
│   ├── app/javascript/src/shopClient/
│   ├── app/javascript/src/strava/
│   ├── app/javascript/src/fileUploader/
│   ├── app/javascript/src/calendarIcon/
│   └── app/javascript/src/narciarskieDziki/
│
├── Traditional Rails Views              ✅ KEEP THESE
│   ├── app/views/admin/
│   ├── app/views/users/
│   ├── app/views/events/
│   └── app/views/layouts/
│
└── Configuration (Webpacker)            ❌ DELETE THESE
    ├── config/webpacker.yml
    ├── babel.config.js
    ├── postcss.config.js
    └── node_modules/ (huge!)
```

### Problems We're Solving

1. ❌ **Webpacker deprecated** - No longer maintained
2. ❌ **Build complexity** - Webpack, Babel, React config
3. ❌ **Slow builds** - 45 seconds in development
4. ❌ **High maintenance** - Two paradigms (React + Rails)
5. ❌ **No mobile apps** - Would need React Native (separate codebase)
6. ❌ **Onboarding time** - 2-3 weeks to learn React/Redux/Webpack

### What's Working (Don't Touch!)

```ruby
# app/views/admin/dashboard.html.slim
.admin-dashboard
  h1 Admin Dashboard
  .stats
    .stat-box Users: #{@users_count}
  = link_to "Manage", admin_users_path
```

**This is perfect!** Server-rendered, fast, maintainable.

**Action**: Leave it exactly as-is ✅

---

## Target Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────┐
│                  Rails 8 Application                     │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │  Hotwire Stack                                  │    │
│  │                                                 │    │
│  │  • Turbo Drive (SPA-like navigation)          │    │
│  │  • Turbo Frames (partial updates)             │    │
│  │  • Turbo Streams (real-time WebSocket)        │    │
│  │  • Stimulus (JavaScript sprinkles)            │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
│  All HTML rendered by Rails (server-side)               │
│  JavaScript only for interactivity                      │
└─────────────────────────────────────────────────────────┘
                      ▲
                      │ HTTP (same HTML)
                      │
        ┌─────────────┴──────────────┐
        │                            │
┌───────▼────────┐         ┌─────────▼────────┐
│  iOS App       │         │  Android App     │
│  Turbo Native  │         │  Turbo Native    │
│                │         │                  │
│  + Strada      │         │  + Strada        │
│  (native       │         │  (native         │
│   features)    │         │   features)      │
└────────────────┘         └──────────────────┘
```

### File Structure After Migration

```
kw-app/
├── app/
│   ├── controllers/
│   │   ├── admin/                    # Unchanged ✅
│   │   ├── users_controller.rb       # Unchanged ✅
│   │   ├── events_controller.rb      # Unchanged ✅
│   │   └── shop/                     # NEW (for rebuilt features)
│   │       ├── products_controller.rb
│   │       └── cart_controller.rb
│   │
│   ├── views/
│   │   ├── admin/                    # Unchanged ✅
│   │   ├── users/                    # Unchanged ✅
│   │   ├── events/                   # Unchanged ✅
│   │   ├── shop/                     # NEW (rebuilt from React)
│   │   │   ├── index.html.slim
│   │   │   ├── cart.html.slim
│   │   │   └── _cart_item.html.slim
│   │   └── layouts/
│   │       └── application.html.slim # Updated for Hotwire
│   │
│   ├── javascript/
│   │   ├── application.js            # NEW (simple entry)
│   │   │
│   │   ├── controllers/              # NEW (Stimulus)
│   │   │   ├── cart_controller.js
│   │   │   ├── search_controller.js
│   │   │   ├── strava_controller.js
│   │   │   ├── calendar_controller.js
│   │   │   └── upload_controller.js
│   │   │
│   │   └── bridges/                  # NEW (native features)
│   │       ├── camera_component.js
│   │       └── menu_component.js
│   │
│   ├── models/                       # Unchanged ✅
│   │   ├── user.rb
│   │   ├── event.rb
│   │   └── product.rb
│   │
│   └── assets/
│       ├── stylesheets/
│       │   └── application.css       # Keep existing CSS
│       └── images/
│
├── ios/                              # NEW (Turbo Native)
│   └── KwApp/
│       ├── AppDelegate.swift
│       └── SceneController.swift
│
├── android/                          # NEW (Turbo Native)
│   └── app/
│       └── src/
│
├── config/
│   ├── importmap.rb                  # NEW (replaces Webpacker)
│   └── routes.rb                     # Updated for new shop routes
│
└── Gemfile                           # Updated for Rails 8 + Hotwire
```

---

## Migration Strategy

### The "Clean Slate" Approach

**Philosophy**: Why convert complex React when we can rebuild simpler?

```
Old React Component:
├─ 200 lines of React
├─ Redux state management
├─ Complex lifecycle hooks
├─ Webpack configuration
└─ Hard to maintain

New Stimulus Version:
├─ 30 lines of JavaScript
├─ Server handles state
├─ Simple controller pattern
└─ Easy to maintain
```

### What Gets Deleted

```bash
# These go away completely:
rm -rf app/javascript/src/          # All React components
rm -rf node_modules/react*          # React dependencies
rm -rf config/webpacker.yml         # Webpacker config
rm -rf babel.config.js              # Babel config
rm -rf postcss.config.js            # PostCSS config
rm package.json                     # Will recreate minimal version
```

### What Gets Kept

```
✅ app/views/admin/        - Already perfect
✅ app/views/users/        - Already perfect
✅ app/views/events/       - Already perfect
✅ app/controllers/        - Business logic unchanged
✅ app/models/             - 100% unchanged
✅ config/routes.rb        - Most routes unchanged
✅ spec/                   - Most tests unchanged
✅ Gemfile                 - Update for Rails 8
✅ Kamal deployment        - Works as-is
```

### What Gets Built Fresh

```
NEW: app/javascript/controllers/    - Stimulus controllers
NEW: app/views/shop/                - Rails views for shop
NEW: ios/                           - Native iOS app
NEW: android/                       - Native Android app
```

### Decision Tree: What to Do With Each Page

```
For every page in your app:

Does it use React?
├─ YES
│  ├─ Delete React component
│  ├─ Create Rails view (server-rendered HTML)
│  ├─ Create Stimulus controller (if interactivity needed)
│  └─ Test new version
│
└─ NO (already Rails view)
   └─ LEAVE IT ALONE ✅
      Optional: Add data-turbo="true" for SPA feel
```

---

## Why This Approach

### Benefits of "Delete & Rebuild"

#### 1. Simpler Than Conversion

**Converting React to Stimulus:**
```
1. Understand complex React component
2. Map Redux state to server state
3. Rewrite in Stimulus
4. Ensure feature parity
5. Test exhaustively
```

**Building fresh with Stimulus:**
```
1. Know what feature should do
2. Build with Rails views + Stimulus
3. Test
4. Done
```

#### 2. Cleaner Code

No legacy patterns, no half-converted code, no "we kept this because..."

Start fresh with best practices.

#### 3. Learning Opportunity

FE developer learns Stimulus by building (not converting).

Better understanding, cleaner implementations.

#### 4. No Coexistence Complexity

**Gradual migration:**
- Two asset pipelines running
- Conditional logic in layouts
- "Which system is this page using?"
- Temporary complexity

**Clean slate:**
- One system (Hotwire)
- Simple setup
- Clear architecture
- No confusion

### Comparison Table

| Approach | Pros | Cons | Timeline |
|----------|------|------|----------|
| **Convert React** | Keep exact behavior | Complex mapping | 12 weeks |
| **Delete & Rebuild** | Clean code, simpler | Need to rebuild features | 10 weeks |
| **Gradual migration** | Lower risk | Two systems coexist | 14 weeks |

**Your choice (Delete & Rebuild) is actually fastest!** ⚡

### Risk Mitigation

**"But what if we lose features?"**

✅ **Solution**: Feature checklist before deleting

```
Shop Feature Checklist:
- [ ] Product listing
- [ ] Add to cart
- [ ] Remove from cart
- [ ] Cart total calculation
- [ ] Checkout flow
- [ ] Order confirmation

Document BEFORE deleting React.
Implement EXACTLY these features.
No features lost.
```

**"What if new version has bugs?"**

✅ **Solution**: Build in staging first

```
1. Keep production running (React version)
2. Build Stimulus version in staging
3. Test thoroughly
4. Only deploy when confident
5. Can rollback if needed
```

---

## Timeline

### 10-Week Detailed Plan

#### Phase 1: Rails 8 Setup (Weeks 1-2)

**Week 1: Preparation**
- [ ] Team alignment meeting
- [ ] Create feature documentation (what React does today)
- [ ] Set up Rails 8 branch
- [ ] Database backup strategy
- [ ] Update Ruby to 3.3.0

**Week 2: Core Upgrade**
- [ ] Update Gemfile (Rails 8, Hotwire)
- [ ] Run `bundle install`
- [ ] Install Hotwire: `rails turbo:install stimulus:install`
- [ ] Delete Webpacker & React completely
- [ ] Update application layout
- [ ] Verify existing Rails views still work
- [ ] Tests passing

**Deliverable**: Rails 8 running, Hotwire installed, React deleted ✅

#### Phase 2: Rebuild Features (Weeks 3-6)

**Week 3: Shop - Product Listing**
- [ ] Create `Shop::ProductsController`
- [ ] Create views: `shop/index.html.slim`
- [ ] Add search with Stimulus
- [ ] Add filters with Stimulus
- [ ] Test thoroughly

**Week 4: Shop - Cart**
- [ ] Create `Shop::CartController`
- [ ] Create cart views
- [ ] Build `cart_controller.js` (Stimulus)
- [ ] Add to cart functionality
- [ ] Update cart dynamically (Turbo Streams)
- [ ] Test checkout flow

**Week 5: Strava Integration**
- [ ] Create `StravaController`
- [ ] OAuth flow (existing or new)
- [ ] Build `strava_controller.js` (Stimulus)
- [ ] Sync activities
- [ ] Display stats
- [ ] Test sync process

**Week 6: Calendar & Upload**
- [ ] Calendar widget with Stimulus
- [ ] File uploader with Stimulus
- [ ] Test all interactions
- [ ] Polish UI/UX

**Deliverable**: All features rebuilt and working ✅

#### Phase 3: Native Apps (Weeks 7-8)

**Week 7: iOS App**
- [ ] Create Xcode project
- [ ] Install Turbo via CocoaPods
- [ ] Basic navigation working
- [ ] Authentication working
- [ ] Test all features in app
- [ ] Add app icon/splash

**Week 8: Android App**
- [ ] Create Android Studio project
- [ ] Install Turbo library
- [ ] Basic navigation working
- [ ] Authentication working
- [ ] Test all features in app
- [ ] Add app icon/splash

**Deliverable**: iOS & Android apps functional ✅

#### Phase 4: Testing & Launch (Weeks 9-10)

**Week 9: QA & Bug Fixes**
- [ ] Full regression testing
- [ ] Performance testing
- [ ] Mobile app testing
- [ ] Fix all bugs
- [ ] Update documentation

**Week 10: Production Launch**
- [ ] Deploy to staging
- [ ] Stakeholder review
- [ ] Deploy to production
- [ ] Submit apps to stores
- [ ] Monitor closely
- [ ] Team celebration! 🎉

**Deliverable**: Live in production, apps submitted ✅

---

## Step-by-Step Migration

### Step 1: Upgrade Rails 8

```bash
# 1. Update Ruby
echo "3.3.0" > .ruby-version
rbenv install 3.3.0
rbenv local 3.3.0

# 2. Update Gemfile
```

```ruby
# Gemfile
source 'https://rubygems.org'
ruby '3.3.0'

# Core
gem 'rails', '~> 8.0'
gem 'bootsnap', require: false
gem 'pg', '~> 1.1'
gem 'puma'

# Hotwire
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'importmap-rails'

# Rails 8 performance
gem 'thruster', require: false, group: [:development, :production]

# Keep existing gems
gem 'devise', '~> 4.8.1'
gem 'sidekiq'
gem 'pagy'
gem 'ransack'
gem 'carrierwave', '~> 3.1.2'
gem 'cancancan', '~> 3.3.0'  # or pundit
gem 'slim-rails'
gem 'kamal', '~> 2.3', require: false, group: [:tools]

# Dry-rb (keep if used)
gem 'dry-monads', '~> 1.3'
gem 'dry-validation', '~> 1.0'

# REMOVE THESE:
# gem 'webpacker'  # or shakapacker
# gem 'react-rails'

group :development, :test do
  gem 'rspec-rails'
  gem 'byebug'
end
```

```bash
# 3. Install
bundle install

# 4. Install Hotwire
rails turbo:install
rails stimulus:install
rails importmap:install

# 5. Run Rails update
bin/rails app:update
```

### Step 2: Delete React Completely

```bash
# Delete React code
rm -rf app/javascript/src/
rm -rf app/javascript/packs/

# Delete Webpacker config
rm -rf config/webpacker.yml
rm -rf config/webpack/
rm -rf babel.config.js
rm -rf postcss.config.js

# Clean node_modules
rm -rf node_modules/
rm -rf yarn.lock
```

### Step 3: Setup Minimal JavaScript

```json
// package.json (recreate minimal version)
{
  "name": "kw-app",
  "private": true,
  "dependencies": {
    "@hotwired/stimulus": "^3.2.2",
    "@hotwired/turbo-rails": "^8.0.4"
  }
}
```

```bash
yarn install
```

```javascript
// app/javascript/application.js
import "@hotwired/turbo-rails"
import "./controllers"

console.log("Hotwire loaded!")
```

```javascript
// app/javascript/controllers/application.js
import { Application } from "@hotwired/stimulus"

const application = Application.start()
application.debug = false
window.Stimulus = application

export { application }
```

```javascript
// app/javascript/controllers/index.js
import { application } from "./application"

// Controllers will be imported here
// import HelloController from "./hello_controller"
// application.register("hello", HelloController)
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
    
    = csrf_meta_tags
    = csp_meta_tag
    
    / Hotwire
    = javascript_importmap_tags
    = stylesheet_link_tag "application", "data-turbo-track": "reload"
  
  body
    = render "layouts/navigation"
    = render "layouts/flash"
    
    main
      = yield
    
    = render "layouts/footer"
```

### Step 5: Configure Importmap

```ruby
# config/importmap.rb
pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

# Pin Stimulus controllers
pin_all_from "app/javascript/controllers", under: "controllers"

# Add libraries as needed (no React!)
# pin "chartkick"
```

### Step 6: Test Existing Pages

```bash
# Start server
bin/rails server

# Visit existing pages
open http://localhost:3000/admin
open http://localhost:3000/users
open http://localhost:3000/events

# They should all work! ✅
```

### Step 7: Build First Feature (Shop)

**Create Controller:**

```ruby
# app/controllers/shop/products_controller.rb
module Shop
  class ProductsController < ApplicationController
    def index
      @products = Product.active
                        .search(params[:query])
                        .page(params[:page])
    end
    
    def show
      @product = Product.find(params[:id])
    end
  end
end
```

**Create View:**

```slim
/ app/views/shop/products/index.html.slim
.shop-products(data-controller="shop")
  .search
    = form_with url: shop_products_path, method: :get do |f|
      = f.text_field :query,
        placeholder: "Search products...",
        data: {
          action: "input->shop#search",
          shop_target: "searchInput"
        }
  
  .products(data-shop-target="results")
    = render @products
  
  = pagy_nav(@pagy) if @pagy
```

**Create Stimulus Controller:**

```javascript
// app/javascript/controllers/shop_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput", "results"]
  
  search() {
    clearTimeout(this.timeout)
    
    this.timeout = setTimeout(() => {
      this.performSearch()
    }, 300)
  }
  
  async performSearch() {
    const query = this.searchInputTarget.value
    const url = `/shop/products?query=${encodeURIComponent(query)}`
    
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

**Register Controller:**

```javascript
// app/javascript/controllers/index.js
import { application } from "./application"
import ShopController from "./shop_controller"

application.register("shop", ShopController)
```

**Test:**

```bash
open http://localhost:3000/shop/products
# Search should work with live updates!
```

---

## Code Examples

### Example 1: Shopping Cart

**Rails Controller:**

```ruby
# app/controllers/shop/carts_controller.rb
module Shop
  class CartsController < ApplicationController
    before_action :authenticate_user!
    
    def show
      @cart = current_user.cart
    end
    
    def add
      @cart = current_user.cart
      @item = @cart.add_item(params[:product_id], params[:quantity] || 1)
      
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to shop_cart_path }
      end
    end
    
    def remove
      @cart = current_user.cart
      @cart.remove_item(params[:id])
      
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to shop_cart_path }
      end
    end
    
    def update_quantity
      @cart = current_user.cart
      @item = @cart.items.find(params[:id])
      @item.update(quantity: params[:quantity])
      
      render partial: "cart_item", locals: { item: @item }
    end
  end
end
```

**Rails View:**

```slim
/ app/views/shop/carts/show.html.slim
div(data-controller="cart")
  h1 Shopping Cart
  
  - if @cart.items.any?
    = turbo_frame_tag "cart-items"
      = render partial: "cart_item", collection: @cart.items
    
    .cart-summary
      .cart-total
        strong Total:
        = number_to_currency(@cart.total)
      
      = link_to "Checkout", shop_checkout_path, class: "btn btn-primary"
  
  - else
    p Your cart is empty
    = link_to "Continue Shopping", shop_products_path, class: "btn"
```

**Partial:**

```slim
/ app/views/shop/carts/_cart_item.html.slim
.cart-item(id=dom_id(cart_item))
  .product-image
    = image_tag cart_item.product.image_url, alt: cart_item.product.name
  
  .product-details
    h3 = cart_item.product.name
    p = number_to_currency(cart_item.product.price)
  
  .quantity
    input(
      type="number"
      value=cart_item.quantity
      min="1"
      data-action="change->cart#updateQuantity"
      data-cart-item-id-param=cart_item.id
    )
  
  .actions
    button(
      data-action="click->cart#removeItem"
      data-cart-item-id-param=cart_item.id
      class="btn btn-danger"
    ) Remove
```

**Stimulus Controller:**

```javascript
// app/javascript/controllers/cart_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  async removeItem(event) {
    const itemId = event.params.itemId
    
    if (!confirm('Remove this item from cart?')) return
    
    try {
      const response = await fetch(`/shop/cart/remove/${itemId}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': this.csrfToken
        }
      })
      
      if (response.ok) {
        // Turbo Stream will handle the removal
      }
    } catch (error) {
      alert('Failed to remove item')
    }
  }
  
  async updateQuantity(event) {
    const itemId = event.params.itemId
    const quantity = event.target.value
    
    try {
      const response = await fetch(`/shop/cart/update_quantity/${itemId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.csrfToken
        },
        body: JSON.stringify({ quantity })
      })
      
      if (response.ok) {
        const html = await response.text()
        event.target.closest('.cart-item').outerHTML = html
      }
    } catch (error) {
      alert('Failed to update quantity')
    }
  }
  
  get csrfToken() {
    return document.querySelector('[name="csrf-token"]').content
  }
}
```

**Turbo Stream Response:**

```ruby
# app/views/shop/carts/remove.turbo_stream.erb
<%= turbo_stream.remove dom_id(@item) %>
<%= turbo_stream.update "cart-total" do %>
  <%= number_to_currency(@cart.total) %>
<% end %>
```

### Example 2: Live Search

**Even Simpler with Turbo Frames:**

```slim
/ app/views/shop/products/index.html.slim
= form_with url: shop_products_path, method: :get, data: { turbo_frame: "products" } do |f|
  = f.text_field :query, 
    placeholder: "Search...",
    data: { action: "input->debounced#submit" }

= turbo_frame_tag "products" do
  = render @products
```

**Debounce Controller:**

```javascript
// app/javascript/controllers/debounced_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit() {
    clearTimeout(this.timeout)
    
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 300)
  }
}
```

**That's it!** Search works with auto-submit and no page reload.

### Example 3: File Upload with Progress

```javascript
// app/javascript/controllers/upload_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "progress", "preview"]
  
  async upload(event) {
    const files = event.target.files
    
    for (const file of files) {
      await this.uploadFile(file)
    }
  }
  
  async uploadFile(file) {
    const formData = new FormData()
    formData.append('file', file)
    
    try {
      const response = await fetch('/upload', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': this.csrfToken
        },
        body: formData
      })
      
      if (response.ok) {
        const data = await response.json()
        this.showPreview(data.url)
      }
    } catch (error) {
      alert('Upload failed')
    }
  }
  
  showPreview(url) {
    const img = document.createElement('img')
    img.src = url
    this.previewTarget.appendChild(img)
  }
  
  get csrfToken() {
    return document.querySelector('[name="csrf-token"]').content
  }
}
```

---

## Team Structure

### Backend Developer (You) - 70% of Work

**Responsibilities:**

✅ **Infrastructure**
- Rails controllers & models
- Database migrations
- Business logic
- Background jobs (Sidekiq)
- Authentication (Devise)
- Authorization (CanCanCan)
- API endpoints (if needed)
- Testing (models, controllers, integration)

✅ **Views**
- HTML structure (Slim templates)
- Server-rendered content
- Turbo Frame placement
- Turbo Stream responses
- Partials

✅ **Deployment**
- Kamal configuration
- Server management
- Database backups
- Monitoring

**Example Daily Task:**

```ruby
# Create new feature
rails g scaffold Event name:string date:datetime

# Add view with Stimulus hook
# app/views/events/index.html.slim
div(data-controller="events")
  = render @events

# Controller handles business logic
def create
  @event = Event.new(event_params)
  if @event.save
    redirect_to @event
  else
    render :new
  end
end
```

### Frontend Developer - 30% of Work

**Responsibilities:**

✅ **JavaScript**
- Stimulus controllers
- Interactive components
- Form validations
- API consumption
- Animations

✅ **Styling**
- CSS/SCSS
- Responsive design
- Component styling
- UI polish

✅ **Native Bridges** (optional)
- Strada components
- Camera access
- GPS/location
- Push notifications

✅ **Testing**
- JavaScript tests
- System tests (with you)

**Example Daily Task:**

```javascript
// Build interactive feature
// app/javascript/controllers/dropdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  
  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }
  
  hide(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }
}
```

### Clear Separation

**You touch:**
- `.rb` files
- `.slim` files (HTML structure)
- `db/` migrations
- `config/` files

**FE dev touches:**
- `.js` files in `app/javascript/controllers/`
- `.css` files
- `.swift` / `.kt` files (native bridges)

**No overlap = No conflicts!**

---

## Frontend Developer Guide

### Welcome! 👋

You'll work with **Stimulus** - a simple JavaScript framework.

### Your Workspace

```
app/javascript/
├── controllers/      ← YOU WORK HERE!
│   ├── cart_controller.js
│   ├── search_controller.js
│   └── your_new_controller.js
│
└── bridges/         ← For native features (optional)
    └── camera_component.js
```

### Stimulus in 5 Minutes

**Concept:** Connect JavaScript to HTML via `data-` attributes.

**Three things:**
1. **Controllers** - JavaScript classes
2. **Targets** - Elements you want to reference
3. **Actions** - Events that trigger methods

**Example:**

```html
<!-- HTML (backend dev writes) -->
<div data-controller="counter">
  <button data-action="click->counter#increment">+</button>
  <span data-counter-target="display">0</span>
</div>
```

```javascript
// JavaScript (you write)
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"]
  
  increment() {
    const value = parseInt(this.displayTarget.textContent)
    this.displayTarget.textContent = value + 1
  }
}
```

**That's it!** No JSX, no build config, no virtual DOM.

### Common Patterns

**Pattern 1: Fetch Data**

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  async loadData() {
    const response = await fetch('/api/data')
    const data = await response.json()
    this.updateUI(data)
  }
}
```

**Pattern 2: Form Handling**

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
      // Success!
    }
  }
  
  get csrfToken() {
    return document.querySelector('[name="csrf-token"]').content
  }
}
```

**Pattern 3: Toggle UI**

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  
  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }
}
```

### Your Daily Workflow

**1. Backend dev creates feature:**
```
"Add live search to products page"
```

**2. They provide:**
- HTML with `data-` attributes
- API endpoint or URL
- Expected behavior

**3. You create controller:**
```javascript
// app/javascript/controllers/product_search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Your implementation
}
```

**4. Test:**
```bash
# Just refresh the page - no build step!
```

**5. Done!**

### Learning Resources

**Documentation:**
- Stimulus Handbook: https://stimulus.hotwired.dev/handbook
- Stimulus Reference: https://stimulus.hotwired.dev/reference

**Video:**
- Search "Stimulus 101" on YouTube (30 min)

**Time to learn:** 
- Day 1: Basics (4 hours)
- Day 2-3: First feature (8 hours)
- Week 1: Comfortable

### Tools

**VS Code Extensions:**
- Stimulus LSP
- Stimulus Autocomplete

**Testing:**
```javascript
// test/javascript/controllers/cart_controller_test.js
import { Application } from "@hotwired/stimulus"
import CartController from "controllers/cart_controller"

describe("CartController", () => {
  it("adds item to cart", () => {
    // Your test
  })
})
```

### Requirements

**You need:**
- ✅ JavaScript (ES6+)
- ✅ DOM manipulation
- ✅ Fetch API
- ✅ CSS/SCSS

**You don't need:**
- ❌ React experience
- ❌ Ruby/Rails knowledge
- ❌ Webpack configuration
- ❌ State management (Redux, etc.)

### First Task: Hello World

Create your first controller:

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

Backend dev creates view:
```slim
div(data-controller="hello")
  input(type="text" data-hello-target="name")
  button(data-action="click->hello#greet") Greet
  div(data-hello-target="output")
```

Test it - it works! 🎉

---

## Development Workflow

### Daily Development

```bash
# Start server (one command)
bin/dev

# This runs (via Procfile.dev):
# - Rails server
# - CSS watching (if using Tailwind)
# That's it! No webpack, no complex builds
```

**Procfile.dev:**
```yaml
web: bin/rails server -p 3000
css: bin/rails tailwindcss:watch
```

### Making Changes

**Backend Developer:**
1. Edit controller/model/view
2. Refresh browser
3. Works immediately

**Frontend Developer:**
1. Edit Stimulus controller
2. Refresh browser
3. Works immediately

**No build step in development!** ⚡

### Git Workflow

**Branching:**
```bash
git checkout -b feature/shop-cart
# Work on feature
git commit -m "feat: add shop cart feature"
git push origin feature/shop-cart
# Create PR
```

**Branch naming:**
- `feature/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code improvements

### Code Review

**Backend dev reviews:**
- Ruby code
- View structure
- Business logic
- Database queries

**Frontend dev reviews:**
- JavaScript code
- UI/UX
- Styling
- Interactions

**Both review:**
- Integration
- User experience
- Testing coverage

---

## Testing

### Backend Tests (RSpec)

```ruby
# spec/models/cart_spec.rb
RSpec.describe Cart, type: :model do
  describe "#add_item" do
    it "adds item to cart" do
      cart = create(:cart)
      product = create(:product)
      
      cart.add_item(product.id)
      
      expect(cart.items.count).to eq(1)
    end
  end
end

# spec/controllers/shop/carts_controller_spec.rb
RSpec.describe Shop::CartsController, type: :controller do
  describe "POST #add" do
    it "adds product to cart" do
      sign_in create(:user)
      product = create(:product)
      
      post :add, params: { product_id: product.id }
      
      expect(response).to be_successful
    end
  end
end

# spec/system/shop_spec.rb
RSpec.describe "Shopping", type: :system do
  it "allows adding product to cart" do
    product = create(:product)
    
    visit shop_products_path
    click_button "Add to Cart"
    
    expect(page).to have_content("Added to cart")
  end
end
```

### Frontend Tests (Optional)

```javascript
// test/javascript/controllers/cart_controller_test.js
import { Application } from "@hotwired/stimulus"
import CartController from "controllers/cart_controller"

describe("CartController", () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <div data-controller="cart">
        <button data-action="click->cart#add">Add</button>
      </div>
    `
    
    const application = Application.start()
    application.register("cart", CartController)
  })
  
  it("handles add click", () => {
    const button = document.querySelector("button")
    button.click()
    // Assert behavior
  })
})
```

### Running Tests

```bash
# Backend tests
bin/rails test
bin/rails spec  # if using RSpec

# System tests (full browser)
bin/rails test:system

# Frontend tests (if configured)
npm test

# Coverage
COVERAGE=true bin/rails test
```

---

## Deployment

### Staging (Kamal)

```bash
# Deploy to staging
kamal deploy -d staging

# Check logs
kamal app logs -d staging -f

# SSH into server
kamal app exec -i -d staging bash
```

### Production (Kamal)

```bash
# 1. Tag release
git tag -a v1.0.0 -m "Rails 8 migration complete"
git push origin v1.0.0

# 2. Deploy
kamal deploy

# 3. Monitor
kamal app logs -f

# 4. Rollback if needed
kamal rollback
```

### iOS App (App Store)

```bash
cd ios

# Update version in Xcode
# Increment build number

# Archive and upload
fastlane release

# Or manually:
xcodebuild archive -scheme KwApp
# Upload via Xcode or Transporter
```

### Android App (Play Store)

```bash
cd android

# Update version in build.gradle

# Build release
./gradlew bundleRelease

# Upload to Play Console
fastlane release
```

### CI/CD (GitHub Actions)

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
      - run: bundle install
      - run: bin/rails test
  
  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy
        run: |
          gem install kamal
          kamal deploy
        env:
          KAMAL_REGISTRY_PASSWORD: ${{ secrets.REGISTRY_PASSWORD }}
```

---

## Success Metrics

### Technical Improvements

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Build time** | 45s | 0s (dev) | Instant |
| **Bundle size** | 250kb | 50kb | 80% smaller |
| **Time to interactive** | 3.5s | 1.5s | 57% faster |
| **Test suite** | 8 min | 5 min | 37% faster |
| **Lighthouse score** | 65 | 90+ | +38% |

### Development Metrics

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Feature time** | 5-7 days | 2-3 days | 2x faster |
| **Maintenance** | 40 hrs/mo | 10 hrs/mo | 75% less |
| **Onboarding** | 2-3 weeks | 2-3 days | 10x faster |
| **Deploy time** | 10 min | 8 min | Faster |

### Business Metrics

| Metric | Before | After | Result |
|--------|--------|--------|
| **Platforms** | Web only | Web + iOS + Android | +200% |
| **Code sharing** | 0% | 95% | Native apps "free" |
| **Team capacity** | 1 dev | 2 devs (parallel) | 2x capacity |

---

## Checklist

### Pre-Migration
- [ ] Team alignment
- [ ] Feature documentation complete
- [ ] Database backup strategy
- [ ] Rollback plan
- [ ] Timeline approved

### Phase 1: Rails 8
- [ ] Ruby 3.3.0 installed
- [ ] Rails 8.0 installed
- [ ] Hotwire installed
- [ ] Webpacker deleted
- [ ] React deleted
- [ ] Existing pages work
- [ ] Tests passing

### Phase 2: Rebuild Features
- [ ] Shop feature rebuilt
- [ ] Strava feature rebuilt
- [ ] Calendar rebuilt
- [ ] Upload rebuilt
- [ ] All features tested
- [ ] Performance validated

### Phase 3: Native Apps
- [ ] iOS app working
- [ ] Android app working
- [ ] Authentication working
- [ ] All features in apps
- [ ] App icons/splash screens

### Phase 4: Launch
- [ ] Staging deployment
- [ ] Production deployment
- [ ] Apps submitted to stores
- [ ] Monitoring active
- [ ] Team trained
- [ ] Documentation complete

---

## Support Resources

### Documentation
- Rails 8 Guides: https://guides.rubyonrails.org/
- Hotwire: https://hotwired.dev/
- Turbo: https://turbo.hotwired.dev/
- Stimulus: https://stimulus.hotwired.dev/
- Turbo Native: https://github.com/hotwired/turbo-ios

### Community
- Hotwire Discussion: https://discuss.hotwired.dev/
- Rails Discord: https://discord.gg/d35t4vr
- Stimulus Components: https://www.stimulus-components.com/

### Learning
- GoRails: https://gorails.com/series/hotwire-rails
- Hotwire Handbook: https://hotwirehandbook.com/

---

## Summary

**What You're Doing:**
1. ✅ Delete React (causes problems)
2. ✅ Keep Rails views (work great!)
3. ✅ Rebuild features with Stimulus (simpler)
4. ✅ Get native apps automatically

**Timeline:** 10 weeks

**Result:**
- 75% less maintenance
- iOS + Android apps included
- 2x faster development
- Simpler codebase
- Happier team

**This is the right approach!** 🚀

---

## Next Steps

**This Week:**
1. Review this document with team
2. Create feature documentation (what React does now)
3. Show FE developer Stimulus basics
4. Get team buy-in

**Next Week:**
1. Start Rails 8 upgrade
2. Delete React
3. Setup Hotwire
4. Build first feature (proof of concept)

**Ready to start?** Let's build something great! 💪