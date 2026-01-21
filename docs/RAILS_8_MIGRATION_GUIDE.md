# Rails 8 Migration & Frontend Work Division

**Strategy**: Delete React → Rebuild with Stimulus → Keep working views as-is

---

## 📋 Executive Summary

### Current State → Target State

| Aspect | Before | After |
|--------|--------|-------|
| **Rails** | 7.0.8 | 8.0 |
| **Ruby** | 3.2.2 | 3.3.0 |
| **Frontend** | React + Webpacker | Stimulus + Importmap |
| **Views** | Slim (working) + React components | ERB (new features) + Slim (existing) |
| **Mobile** | None | Turbo Native (iOS + Android) |
| **Maintenance** | Complex (React build pipeline) | Simple (server-rendered HTML) |

### Goals

1. ✅ Remove React complexity
2. ✅ Enable generic frontend developer to work independently
3. ✅ Build native iOS/Android apps from same codebase
4. ✅ 75% less maintenance, 2x faster development

---

## 🎯 Migration Strategy

### What Gets Deleted

```
❌ DELETE COMPLETELY:
├── app/javascript/src/shopAdmin/
├── app/javascript/src/shopClient/
├── app/javascript/src/strava/
├── app/javascript/src/calendar/
├── app/javascript/src/fileUploader/
├── config/webpack/
├── config/webpacker.yml
└── package.json (React dependencies)
```

### What Gets Kept

```
✅ KEEP AS-IS (Working Slim views):
├── app/views/admin/dashboard.html.slim
├── app/views/users/index.html.slim
├── app/views/layouts/application.html.slim
└── Any other working Slim templates
```

### What Gets Rebuilt

```
🔨 REBUILD WITH STIMULUS:
├── Shop features → ERB + Stimulus
├── Strava integration → ERB + Stimulus
├── Calendar widgets → ERB + Stimulus
└── File uploader → ERB + Stimulus
```

### Decision Tree

```
Is it a React component?
├─ YES → Delete it, rebuild with Stimulus (ERB + JS)
│
Is it working Slim template?
├─ YES → Keep it as-is
│   └─ Only convert to ERB if FE dev needs to refactor
│
Is it a new feature?
└─ YES → Build with ERB (easier for FE developers)
```

---

## 👥 Team Responsibilities

### Backend Developer (You) - 70% Work

**You Own:**
```ruby
# 1. Controllers - Provide data
class Shop::ProductsController < ApplicationController
  def index
    @products = Product.active
                      .search(params[:query])
                      .page(params[:page])
    # Stop here - FE dev handles the view
  end
end

# 2. Models - Business logic
class Product < ApplicationRecord
  validates :name, presence: true
  scope :active, -> { where(active: true) }
  
  def discounted_price
    price * (1 - discount_percentage)
  end
end

# 3. Database migrations
class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.decimal :price
      t.boolean :active, default: true
      t.timestamps
    end
  end
end

# 4. Routes
Rails.application.routes.draw do
  namespace :shop do
    resources :products
  end
end

# 5. Tests (RSpec)
# 6. Deployment (Kamal)
# 7. Database management
```

**You DON'T Touch:**
- ❌ View files (ERB/Slim)
- ❌ CSS styling
- ❌ JavaScript/Stimulus
- ❌ UI/UX decisions

### Frontend Developer - 30% Work

**FE Dev Owns:**
```
app/
├── views/shop/products/
│   ├── index.html.erb           ← Complete HTML
│   ├── show.html.erb            ← Complete HTML
│   └── _product.html.erb        ← Partials
│
├── javascript/controllers/
│   ├── shop_controller.js       ← Stimulus interactivity
│   └── cart_controller.js
│
└── assets/stylesheets/
    ├── application.css
    └── shop.css                  ← All styling
```

**FE Dev DON'T Need:**
- ❌ Ruby/Rails knowledge
- ❌ Database concepts
- ❌ Deployment knowledge
- ❌ Backend testing

---

## 📁 File Format Strategy

### Keep Slim When:
- ✅ Existing page works perfectly
- ✅ No interactive features needed
- ✅ No immediate refactoring planned
- ✅ Admin panels, dashboards

### Use ERB When:
- ✅ New feature being built
- ✅ React component being replaced
- ✅ FE developer needs to work on it
- ✅ Any frontend refactoring

**Why ERB?** Standard HTML - any frontend developer can work with it immediately.

---

## 🔨 Code Examples

### Example 1: Shopping Cart

**Backend (You):**
```ruby
# app/controllers/shop/carts_controller.rb
module Shop
  class CartsController < ApplicationController
    def show
      @cart = current_user.cart
    end

    def add
      @cart = current_user.cart
      @product = Product.find(params[:product_id])
      @cart.add_item(@product, quantity: params[:quantity])
      
      respond_to do |format|
        format.html { redirect_to shop_cart_path }
        format.turbo_stream # Triggers app/views/shop/carts/add.turbo_stream.erb
      end
    end
  end
end
```

**Frontend (FE Dev):**
```erb
<!-- app/views/shop/carts/show.html.erb -->
<div data-controller="cart">
  <h1>Your Cart</h1>
  
  <div id="cart-items">
    <%= render @cart.items %>
  </div>
  
  <div class="cart-summary">
    <p>Total: $<span data-cart-target="total"><%= @cart.total %></span></p>
    <button data-action="click->cart#checkout">Checkout</button>
  </div>
</div>
```

```javascript
// app/javascript/controllers/cart_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["total"]
  
  async removeItem(event) {
    const itemId = event.target.dataset.itemId
    
    const response = await fetch(`/shop/cart/remove/${itemId}`, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": this.csrfToken,
        "Accept": "text/vnd.turbo-stream.html"
      }
    })
    
    // Turbo Stream automatically updates the DOM
  }
  
  get csrfToken() {
    return document.querySelector("[name='csrf-token']").content
  }
}
```

```css
/* app/assets/stylesheets/shop.css */
.cart-page {
  max-width: 800px;
  margin: 0 auto;
}

.cart-item {
  display: flex;
  gap: 1rem;
  padding: 1rem;
  border-bottom: 1px solid #eee;
}
```

### Example 2: Live Search

**Backend (You):**
```ruby
class Shop::ProductsController < ApplicationController
  def index
    @products = Product.active
    @products = @products.search(params[:q]) if params[:q].present?
    @products = @products.page(params[:page])
  end
end
```

**Frontend (FE Dev):**
```erb
<!-- app/views/shop/products/index.html.erb -->
<div data-controller="search">
  <input 
    type="text" 
    data-search-target="input"
    data-action="input->search#search"
    placeholder="Search products..."
  >
  
  <div id="products" data-search-target="results">
    <%= render @products %>
  </div>
</div>
```

```javascript
// app/javascript/controllers/search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]
  
  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.performSearch()
    }, 300)
  }
  
  async performSearch() {
    const query = this.inputTarget.value
    const response = await fetch(`/shop/products?q=${query}`, {
      headers: { "Accept": "text/html" }
    })
    const html = await response.text()
    this.resultsTarget.innerHTML = html
  }
}
```

---

## 📅 Timeline: 10 Weeks

### Phase 1: Rails 8 Setup (Weeks 1-2)
- [ ] Update Ruby to 3.3.0
- [ ] Update Rails to 8.0
- [ ] Delete React code completely
- [ ] Install Hotwire (Turbo + Stimulus)
- [ ] Setup Importmap
- [ ] Convert critical Slim → ERB (if needed)
- [ ] Test existing pages still work

### Phase 2: Rebuild Features (Weeks 3-6)
- [ ] Week 3: Shop product listing + search
- [ ] Week 4: Shopping cart + checkout
- [ ] Week 5: Strava integration UI
- [ ] Week 6: Calendar + file uploader

### Phase 3: Native Apps (Weeks 7-8)
- [ ] Setup Turbo Native iOS
- [ ] Setup Turbo Native Android
- [ ] Test key flows in native apps
- [ ] Add Strada bridges (camera, notifications)

### Phase 4: Testing & Launch (Weeks 9-10)
- [ ] Full regression testing
- [ ] Performance testing
- [ ] Deploy to production (Kamal)
- [ ] Submit apps to stores

---

## 🚀 Step-by-Step Migration

### Step 1: Upgrade Rails 8

```bash
# Update Ruby
echo "3.3.0" > .ruby-version
chruby 3.3.0

# Update Gemfile
gem "rails", "~> 8.0"
gem "turbo-rails"
gem "stimulus-rails"
gem "importmap-rails"

bundle update rails
bin/rails app:update
```

### Step 2: Delete React Completely

```bash
# Delete React code
rm -rf app/javascript/src/
rm -rf app/javascript/packs/
rm -rf node_modules/

# Delete Webpacker
rm -rf config/webpack/
rm config/webpacker.yml
rm bin/webpack
rm bin/webpack-dev-server

# Remove from Gemfile
bundle remove webpacker
```

### Step 3: Setup Hotwire

```bash
# Install Hotwire
bin/rails turbo:install
bin/rails stimulus:install
bin/rails importmap:install

# Create minimal package.json
cat > package.json << 'EOF'
{
  "name": "kw-app",
  "private": true,
  "dependencies": {
    "@hotwired/stimulus": "^3.2.2",
    "@hotwired/turbo-rails": "^8.0.0"
  }
}
EOF
```

### Step 4: Update Layout

```erb
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html>
  <head>
    <title>KW App</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
```

### Step 5: Create First Stimulus Controller

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

```erb
<!-- Test view -->
<div data-controller="hello">
  <input data-hello-target="name" type="text" placeholder="Your name">
  <button data-action="click->hello#greet">Greet</button>
  <p data-hello-target="output"></p>
</div>
```

---

## 🔄 Workflow: Building a New Feature

### Example: Shop Cart Feature

**Step 1: Backend (You)**
```ruby
# 1. Create migration
bin/rails g migration CreateCarts user:references
bin/rails g migration CreateCartItems cart:references product:references quantity:integer

# 2. Create models
class Cart < ApplicationRecord
  belongs_to :user
  has_many :items, class_name: "CartItem"
  
  def total
    items.sum { |item| item.product.price * item.quantity }
  end
end

# 3. Create controller
class Shop::CartsController < ApplicationController
  def show
    @cart = current_user.cart
  end
  
  def add
    @cart = current_user.cart
    @product = Product.find(params[:product_id])
    @cart.add_item(@product, quantity: params[:quantity])
    
    respond_to do |format|
      format.turbo_stream
    end
  end
end

# 4. Add routes
namespace :shop do
  resource :cart, only: [:show] do
    post :add
    delete :remove
  end
end

# 5. Write tests
RSpec.describe Cart do
  it "calculates total correctly" do
    # test code
  end
end
```

**Step 2: Frontend Developer**
```
1. Create view: app/views/shop/carts/show.html.erb
2. Create partial: app/views/shop/carts/_item.html.erb
3. Create Stimulus controller: app/javascript/controllers/cart_controller.js
4. Create CSS: app/assets/stylesheets/cart.css
5. Test in browser
```

**Communication:**
- Backend provides: `@cart`, `@cart.items`, `@cart.total`
- Frontend uses: Those variables in ERB
- API contract: Documented in `docs/API_CONTRACTS.md`

---

## 📚 Frontend Developer Quick Start

### What You Need to Know

**HTML + CSS + JavaScript** - that's it!

**Stimulus in 5 minutes:**
```html
<!-- 1. Add controller -->
<div data-controller="counter">
  <!-- 2. Add target -->
  <span data-counter-target="count">0</span>
  <!-- 3. Add action -->
  <button data-action="click->counter#increment">+</button>
</div>
```

```javascript
// app/javascript/controllers/counter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["count"]
  
  increment() {
    const value = parseInt(this.countTarget.textContent)
    this.countTarget.textContent = value + 1
  }
}
```

**That's it!** No build steps, no React complexity.

### Common Patterns

**1. Fetch data:**
```javascript
async loadData() {
  const response = await fetch("/api/products")
  const data = await response.json()
  // Update DOM
}
```

**2. Submit form:**
```javascript
async submit(event) {
  event.preventDefault()
  const formData = new FormData(this.element)
  
  const response = await fetch("/shop/cart", {
    method: "POST",
    body: formData,
    headers: {
      "X-CSRF-Token": this.csrfToken
    }
  })
}

get csrfToken() {
  return document.querySelector("[name='csrf-token']").content
}
```

**3. Toggle visibility:**
```javascript
static targets = ["content"]

toggle() {
  this.contentTarget.classList.toggle("hidden")
}
```

### Your Daily Workflow

```bash
# 1. Start development
docker-compose up

# 2. Make changes
# - Edit ERB files in app/views/
# - Edit JS in app/javascript/controllers/
# - Edit CSS in app/assets/stylesheets/

# 3. Refresh browser (Turbo handles it!)

# 4. Push to git
git add .
git commit -m "Add shop cart feature"
git push
```

---

## 🧪 Testing

### Backend Tests (RSpec)
```ruby
# spec/models/cart_spec.rb
RSpec.describe Cart do
  describe "#total" do
    it "calculates sum of all items" do
      cart = create(:cart)
      create(:cart_item, cart: cart, price: 10, quantity: 2)
      
      expect(cart.total).to eq(20)
    end
  end
end

# spec/requests/shop/carts_spec.rb
RSpec.describe "Shop::Carts" do
  describe "POST /shop/cart/add" do
    it "adds product to cart" do
      product = create(:product)
      
      post shop_cart_add_path, params: { product_id: product.id }
      
      expect(response).to have_http_status(:success)
    end
  end
end
```

### Frontend Tests (Optional)
```javascript
// Use browser testing or skip it
// Stimulus is simple enough that manual testing works
```

---

## 🚢 Deployment

### Production (Kamal)

```bash
# Deploy to production
ssh ubuntu@146.59.44.70
kamal deploy

# View logs
kamal app logs -f

# Rollback if needed
kamal rollback
```

### iOS App (Turbo Native)

```bash
# Setup once
cd ios
pod init
# Add Turbo and Strada to Podfile
pod install

# Deploy
# Submit to App Store via Xcode
```

---

## ✅ Success Metrics

### Technical
- ✅ Bundle size: 2MB → 200KB (90% reduction)
- ✅ Build time: 3min → 10sec (95% faster)
- ✅ First load: 3s → 0.8s (3.7x faster)
- ✅ Native apps: 0 → 2 (iOS + Android)

### Development
- ✅ New feature time: 3 days → 1 day
- ✅ Frontend dev onboarding: 1 week → 1 day
- ✅ Deploy time: 15min → 2min

---

## 📝 Checklist

### Pre-Migration
- [ ] Backup database
- [ ] Document all React features
- [ ] Create staging environment
- [ ] Review this guide with team

### Phase 1: Rails 8
- [ ] Update Ruby 3.3.0
- [ ] Update Rails 8.0
- [ ] Delete React code
- [ ] Install Hotwire
- [ ] Test existing pages

### Phase 2: Rebuild Features
- [ ] Shop (products, cart, checkout)
- [ ] Strava integration
- [ ] Calendar widgets
- [ ] File uploader

### Phase 3: Native Apps
- [ ] iOS app setup
- [ ] Android app setup
- [ ] Test in native wrappers

### Phase 4: Launch
- [ ] Full testing
- [ ] Deploy production
- [ ] Submit to app stores
- [ ] Monitor metrics

---

## 🎓 Learning Resources

**Hotwire:**
- https://hotwired.dev
- https://turbo.hotwired.dev
- https://stimulus.hotwired.dev

**Turbo Native:**
- https://github.com/hotwired/turbo-ios
- https://github.com/hotwired/turbo-android

**Rails 8:**
- https://guides.rubyonrails.org

---

## 📋 Summary

### What Changes
1. ❌ Delete React completely
2. 🔨 Rebuild features with Stimulus
3. ✅ Keep working Slim views
4. 📱 Add native mobile apps

### Who Does What
- **Backend (You)**: Models, controllers, routes, tests, deployment
- **Frontend Dev**: ERB views, CSS, Stimulus JS, UI/UX

### Result
- 75% less maintenance
- 2x faster development
- Native apps included
- Any frontend dev can contribute

---

## 🚀 Next Steps

1. **Today**: Review this guide
2. **This Week**: Backup DB, setup staging
3. **Week 1-2**: Rails 8 upgrade, delete React
4. **Week 3-6**: Rebuild features with FE dev
5. **Week 7-8**: Native apps
6. **Week 9-10**: Launch

**Questions?** Refer to:
- `docs/API_CONTRACTS.md` - Backend → Frontend data contracts
- `docs/STIMULUS_PATTERNS.md` - Common JS patterns
- `CLAUDE.md` - Development guidelines

---

**Ready to start!** 🎉