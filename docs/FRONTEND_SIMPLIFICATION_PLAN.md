# Frontend Simplification Plan for Rails 8
## Remove React, Embrace Hotwire & Turbo Native

**Status**: READY FOR IMPLEMENTATION  
**Timeline**: 6 weeks  
**Complexity**: LOW-MEDIUM  
**Primary Goal**: Server-rendered HTML + Hotwire Native compatibility

---

## 🎯 Executive Summary

### The Big Picture

**What we're doing**: Remove React entirely, use Rails 8's server-rendered HTML with Hotwire/Turbo Native support

**Why now**:
- Webpacker is deprecated (security risk)
- React is massive overkill for 3 simple components
- Rails 8 + Hotwire Native = perfect for mobile apps
- 90% reduction in JavaScript complexity

**Philosophy**: 
```
Server-rendered HTML first
→ Progressive enhancement with minimal JS
→ Works perfectly in Turbo Native (iOS/Android)
→ Zero build step, zero npm dependencies
```

### Current vs Target

| Aspect | Current (React) | Target (Rails 8) |
|--------|----------------|------------------|
| **Asset Pipeline** | Webpacker 5.2.1 | Propshaft |
| **JavaScript** | React 17 (~500KB) | Vanilla JS (~10KB) |
| **Build Tool** | Webpack + Babel | None (importmap) |
| **Build Time** | 30-60 seconds | <2 seconds |
| **Mobile Support** | WebView | Turbo Native |
| **Dependencies** | 200+ npm packages | 0 npm packages |
| **Maintenance** | Complex | Simple |

### The 3 React Components

All 3 components are **simple data displays** that don't need React:

1. **Events Calendar** (Home page) - Just shows 3 upcoming events
2. **Narciarskie Dziki Rankings** - Tables with tabs
3. **Strava Integration** - List with checkboxes

**Key insight**: None of these need client-side state management, routing, or complex interactions. They're perfect for server-rendered HTML.

---

## 🏗️ Architecture: Rails 8 + Hotwire Native

### The Stack

```
┌─────────────────────────────────────────┐
│         Web Browsers & Mobile Apps      │
├─────────────────────────────────────────┤
│              Turbo Native               │
│         (iOS + Android Wrapper)         │
├─────────────────────────────────────────┤
│               Hotwire                   │
│   • Turbo Drive (page acceleration)    │
│   • Turbo Frames (partial updates)     │
│   • Turbo Streams (real-time)          │
├─────────────────────────────────────────┤
│            Rails 8 Server               │
│      (Renders HTML, handles logic)      │
├─────────────────────────────────────────┤
│              Propshaft                  │
│        (Simple asset delivery)          │
└─────────────────────────────────────────┘
```

### Why This Works

**Server-side rendering**:
- HTML generated on server
- Full page on first load
- SEO-friendly
- Works without JavaScript

**Turbo Drive**:
- Intercepts link clicks
- Fetches via AJAX
- Replaces <body> content
- Feels like SPA
- No code needed!

**Turbo Frames**:
- Update parts of page
- Tab switching without full reload
- Forms submit in-place
- Minimal HTML attributes

**Turbo Native**:
- Wraps web view
- Native navigation
- iOS + Android apps
- Same codebase!

---

## 📋 Migration Plan: 6 Weeks

### Week 1: Setup Rails 8 Asset Pipeline

**Goal**: Get Propshaft + Importmap working alongside existing React

#### Tasks

1. **Install Propshaft**
```ruby
# Gemfile
gem "propshaft"
```

```bash
bundle install
```

2. **Install Importmap**
```bash
bundle add importmap-rails
bin/rails importmap:install
```

3. **Install Hotwire**
```bash
bundle add turbo-rails stimulus-rails
bin/rails turbo:install stimulus:install
```

4. **Configure Asset Paths**
```ruby
# config/application.rb
config.assets.paths << Rails.root.join("app/assets/images")
config.assets.paths << Rails.root.join("app/assets/stylesheets")
config.assets.paths << Rails.root.join("app/assets/javascripts")

# Keep React files excluded during migration
config.assets.excluded_paths << Rails.root.join("app/javascript")
```

5. **Test Setup**
```bash
# Development
bin/rails server
# Visit pages - everything should still work

# Production build test
RAILS_ENV=production bin/rails assets:precompile
```

**Success Criteria**:
- [ ] Propshaft compiles assets
- [ ] Existing React components still work
- [ ] Turbo Drive accelerates page navigation
- [ ] No console errors

---

### Week 2: Replace Events Calendar (Simplest)

**Goal**: First React component → pure server-rendered HTML

#### Current React Version

```javascript
// Fetches /api/events.json
// Renders 3 events with calendar icons
// ~80KB bundle impact
```

#### New Server-Rendered Version

**Step 1: Controller**
```ruby
# app/controllers/pages_controller.rb
class PagesController < ApplicationController
  def home
    @upcoming_events = Event.upcoming.published.limit(3)
  end
end
```

**Step 2: Partial**
```slim
/ app/views/events/_calendar_widget.html.slim
.events-calendar
  - events.each do |event|
    .event-item
      = link_to event_path(event), class: "event-link" do
        .calendar-icon
          .calendar-month= event.date.strftime("%b")
          .calendar-day= event.date.day
        .event-details
          h4.event-name= event.name
          p.event-location= event.location
          time.event-date datetime=event.date.iso8601
            = l(event.date, format: :short)
```

**Step 3: Use in Home Page**
```slim
/ app/views/pages/home.html.slim
section.upcoming-events
  .section-header
    h3 Nadchodzące wydarzenia
    = link_to "Zobacz wszystkie", events_path, class: "view-all"
  
  = render "events/calendar_widget", events: @upcoming_events
```

**Step 4: Optional - Auto-refresh with Turbo Frame**
```slim
/ If you want it to refresh without reload
= turbo_frame_tag "events_widget", 
                  src: events_widget_path, 
                  loading: :lazy,
                  data: { turbo_frame: "events_widget" } do
  = render "events/calendar_widget", events: @upcoming_events
```

**Step 5: Remove React Files**
```bash
rm app/javascript/packs/homepage_components.js
rm app/javascript/src/eventsCalendar*.js
```

**Benefits**:
✅ No JavaScript needed (works in Turbo Native immediately)
✅ SEO-friendly (content in HTML)
✅ Faster initial render
✅ Reduced bundle by 80KB

**Testing**:
- [ ] Events display correctly
- [ ] Links work
- [ ] Mobile responsive
- [ ] Works without JavaScript

---

### Week 3: Replace Narciarskie Dziki Rankings

**Goal**: Tabbed rankings with server-rendered HTML

#### New Implementation

**Step 1: Controller**
```ruby
# app/controllers/rankings_controller.rb
class RankingsController < ApplicationController
  def narciarskie_dziki
    @season = params[:season] || "all"
    @gender = params[:gender] || "all"
    
    @rankings = NarciarskieDziki::Ranking
      .includes(:user, :last_activity)
      .for_season(@season)
      .for_gender(@gender)
      .order(total_meters: :desc)
      .limit(50)
    
    respond_to do |format|
      format.html
      format.turbo_stream # For seamless tab switching
    end
  end
end
```

**Step 2: Routes**
```ruby
# config/routes.rb
get "rankings/narciarskie-dziki", to: "rankings#narciarskie_dziki", as: :rankings
```

**Step 3: Main View with Tabs**
```slim
/ app/views/rankings/narciarskie_dziki.html.slim

.rankings-page
  h2 Narciarskie Dziki - Ranking
  
  / Gender tabs
  nav.tabs-nav role="tablist"
    ul.tabs data-tabs="true" id="gender-tabs"
      li.tabs-title class=("is-active" if @gender == "all")
        = link_to "Wszyscy", 
                  rankings_path(season: @season, gender: "all"),
                  data: { turbo_frame: "rankings_content" }
      li.tabs-title class=("is-active" if @gender == "female")
        = link_to "Kobiety", 
                  rankings_path(season: @season, gender: "female"),
                  data: { turbo_frame: "rankings_content" }
      li.tabs-title class=("is-active" if @gender == "male")
        = link_to "Mężczyźni", 
                  rankings_path(season: @season, gender: "male"),
                  data: { turbo_frame: "rankings_content" }
  
  / Season tabs
  nav.tabs-nav role="tablist"
    ul.tabs data-tabs="true" id="season-tabs"
      li.tabs-title class=("is-active" if @season == "all")
        = link_to "Cały sezon", 
                  rankings_path(season: "all", gender: @gender),
                  data: { turbo_frame: "rankings_content" }
      li.tabs-title class=("is-active" if @season == "winter")
        = link_to "Zima", 
                  rankings_path(season: "winter", gender: @gender),
                  data: { turbo_frame: "rankings_content" }
      li.tabs-title class=("is-active" if @season == "spring")
        = link_to "Wiosna", 
                  rankings_path(season: "spring", gender: @gender),
                  data: { turbo_frame: "rankings_content" }
  
  / Content area (updates via Turbo Frame)
  = turbo_frame_tag "rankings_content" do
    = render "rankings/table", rankings: @rankings
```

**Step 4: Table Partial**
```slim
/ app/views/rankings/_table.html.slim

table.stack.rankings-table
  thead
    tr
      th.text-center width="60" Miejsce
      th Kto?
      th Ostatnie przejście
      th.text-right Metrów
      th.text-right Przejść
  tbody
    - rankings.each_with_index do |ranking, index|
      tr class=(cycle("odd", "even"))
        td.text-center.ranking-position
          span.badge.secondary= index + 1
        td.user-info
          = link_to ranking.user.name, user_path(ranking.user), 
                    class: "user-name"
          - if ranking.user.location.present?
            br
            small.text-muted= ranking.user.location
        td.last-activity
          - if ranking.last_activity
            = link_to ranking.last_activity.route.name, 
                      route_path(ranking.last_activity.route),
                      class: "route-name"
            br
            small.activity-date
              = l(ranking.last_activity.date, format: :short)
          - else
            span.text-muted Brak
        td.text-right.total-meters
          strong= number_with_delimiter(ranking.total_meters)
          = " m"
        td.text-right.activities-count
          = ranking.activities_count

    - if rankings.empty?
      tr
        td colspan="5" class="text-center"
          p.text-muted Brak danych dla wybranych kryteriów
```

**How It Works**:
1. User clicks tab → URL changes with query params
2. `data: { turbo_frame: "rankings_content" }` tells Turbo which frame to update
3. Server renders only the table
4. Turbo replaces content inside frame
5. URL updates (back button works!)
6. No page reload, no JavaScript needed

**Benefits**:
✅ Works without JavaScript (tabs are links)
✅ Back button works (proper URLs)
✅ Turbo Native compatible
✅ Foundation CSS tabs still work
✅ Easy to cache
✅ SEO-friendly

**Testing**:
- [ ] Tables display correctly
- [ ] Tab switching works
- [ ] URL updates
- [ ] Back button works
- [ ] Mobile responsive
- [ ] Works in Turbo Native

---

### Week 4: Replace Strava Integration

**Goal**: Activity list with bulk actions (most complex)

#### New Implementation

**Step 1: Controller**
```ruby
# app/controllers/strava/activities_controller.rb
class Strava::ActivitiesController < ApplicationController
  def index
    @activities = current_user.strava_activities
                               .unimported
                               .order(start_date: :desc)
                               .page(params[:page])
                               .per(20)
  end
  
  def import_selected
    activity_ids = params[:activity_ids] || []
    
    if activity_ids.any?
      @activities = current_user.strava_activities.where(id: activity_ids)
      @activities.each do |activity|
        StravaImportJob.perform_later(activity.id, current_user.id)
      end
      
      flash.now[:success] = "Rozpoczęto import #{@activities.count} aktywności"
    else
      flash.now[:alert] = "Nie wybrano żadnych aktywności"
    end
    
    # Reload list and show flash message
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("strava_list", 
            partial: "strava/activities/list",
            locals: { activities: current_user.strava_activities.unimported }),
          turbo_stream.prepend("flash_messages",
            partial: "shared/flash")
        ]
      end
      format.html { redirect_to strava_activities_path }
    end
  end
  
  def import
    @activity = current_user.strava_activities.find(params[:id])
    StravaImportJob.perform_later(@activity.id, current_user.id)
    
    flash[:success] = "Rozpoczęto import aktywności: #{@activity.name}"
    redirect_to strava_activities_path
  end
end
```

**Step 2: Routes**
```ruby
# config/routes.rb
namespace :strava do
  resources :activities, only: [:index] do
    collection do
      post :import_selected
    end
    member do
      post :import
    end
  end
end
```

**Step 3: Main View**
```slim
/ app/views/strava/activities/index.html.slim

.strava-activities-page
  h2 Aktywności ze Strava
  
  #flash_messages
    = render "shared/flash" if flash.any?
  
  = form_with url: import_selected_strava_activities_path, 
              method: :post,
              id: "import_form" do |f|
    
    .form-actions
      = f.button type: "submit", 
                 class: "button primary",
                 id: "import_button",
                 disabled: true,
                 data: { 
                   controller: "strava-bulk-import",
                   strava_bulk_import_target: "submitButton"
                 } do
        | Importuj zaznaczone (0)
    
    #strava_list data-controller="strava-bulk-import"
      = render "strava/activities/list", activities: @activities
    
    - if @activities.next_page
      .pagination
        = link_to "Załaduj więcej", 
                  strava_activities_path(page: @activities.next_page),
                  class: "button secondary"
```

**Step 4: List Partial**
```slim
/ app/views/strava/activities/_list.html.slim

table.strava-activities-table.stack
  thead
    tr
      th.checkbox-column
        = check_box_tag "select_all", 
                        "1", 
                        false,
                        data: { 
                          action: "strava-bulk-import#toggleAll",
                          strava_bulk_import_target: "selectAll"
                        }
      th Nazwa
      th Data
      th Typ
      th.text-right Dystans
      th.text-right Wznios
      th.text-center Akcje
  tbody
    - activities.each do |activity|
      tr
        td.checkbox-column
          = check_box_tag "activity_ids[]", 
                          activity.id, 
                          false,
                          data: { 
                            action: "strava-bulk-import#updateCounter",
                            strava_bulk_import_target: "checkbox"
                          }
        td.activity-name
          strong= activity.name
        td.activity-date
          = l(activity.start_date, format: :short)
        td.activity-type
          span.label.secondary= activity.type
        td.text-right.activity-distance
          = "#{(activity.distance / 1000).round(2)} km"
        td.text-right.activity-elevation
          = "#{activity.total_elevation_gain.round(0)} m"
        td.text-center.activity-actions
          = button_to "Importuj", 
                      import_strava_activity_path(activity),
                      method: :post,
                      class: "button tiny",
                      form: { data: { turbo: true } }

    - if activities.empty?
      tr
        td colspan="7" class="text-center"
          p.text-muted Brak aktywności do importu
```

**Step 5: Minimal JavaScript (Stimulus Controller)**
```javascript
// app/assets/javascripts/controllers/strava_bulk_import_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "selectAll", "submitButton"]
  
  connect() {
    this.updateCounter()
  }
  
  toggleAll(event) {
    const checked = event.target.checked
    this.checkboxTargets.forEach(cb => cb.checked = checked)
    this.updateCounter()
  }
  
  updateCounter() {
    const count = this.selectedCheckboxes.length
    
    // Update button
    this.submitButtonTarget.textContent = `Importuj zaznaczone (${count})`
    this.submitButtonTarget.disabled = count === 0
    
    // Update "select all" state
    if (this.hasSelectAllTarget) {
      const total = this.checkboxTargets.length
      this.selectAllTarget.checked = count === total && total > 0
      this.selectAllTarget.indeterminate = count > 0 && count < total
    }
  }
  
  get selectedCheckboxes() {
    return this.checkboxTargets.filter(cb => cb.checked)
  }
}
```

**Step 6: Flash Partial**
```slim
/ app/views/shared/_flash.html.slim
- flash.each do |type, message|
  .callout class=flash_class(type) data-closable=""
    = message
    button.close-button aria-label="Dismiss alert" type="button" data-close=""
      span aria-hidden="true" &times;
```

**Benefits**:
✅ Form works without JavaScript
✅ Checkboxes need minimal JS (only for counter)
✅ Turbo Streams for smooth updates
✅ Works in Turbo Native
✅ No toast library needed (use Rails flash)

**Testing**:
- [ ] Activities list loads
- [ ] Individual import works
- [ ] Bulk import works
- [ ] Select all works
- [ ] Counter updates
- [ ] Flash messages appear
- [ ] Pagination works

---

### Week 5: Remove React & Webpacker Completely

**Goal**: Clean house

#### Step 1: Remove npm Packages

```bash
# Remove all React and Webpacker dependencies
npm uninstall \
  @babel/preset-react \
  @rails/webpacker \
  axios \
  babel-plugin-transform-react-remove-prop-types \
  draft-js \
  prop-types \
  react \
  react-calendar-icon \
  react-dom \
  react-draft-wysiwyg \
  react-quill \
  react-redux \
  react-router-dom \
  react-toastify \
  redux \
  styled-jss \
  whatwg-fetch \
  webpack-dev-server

# Or just delete package.json if no other deps
rm package.json yarn.lock
```

#### Step 2: Remove Webpacker Gem

```ruby
# Gemfile - DELETE this line
gem '@rails/webpacker'

# Then
bundle install
```

#### Step 3: Delete Files

```bash
# React source
rm -rf app/javascript/packs
rm -rf app/javascript/src

# Webpacker config
rm babel.config.js
rm postcss.config.js
rm config/webpacker.yml

# Node artifacts
rm -rf node_modules
rm package-lock.json

# Webpacker initializer (if exists)
rm config/initializers/webpacker.rb
```

#### Step 4: Clean Views

Remove all instances of:
```slim
/ DELETE these:
javascript_pack_tag
stylesheet_pack_tag
```

#### Step 5: Update Application Layout

```slim
/ app/views/layouts/application.html.slim
doctype html
html lang="en"
  head
    meta charset="utf-8"
    meta name="viewport" content="width=device-width, initial-scale=1.0"
    
    title = content_for?(:title) ? yield(:title) : t('title')
    
    / Propshaft assets
    = stylesheet_link_tag "application", "data-turbo-track": "reload"
    = javascript_importmap_tags
    = csrf_meta_tags
    
  body
    = render "layouts/top_bar"
    = render "layouts/flash_messages"
    = yield
```

#### Step 6: Update Docker

```dockerfile
# Dockerfile - REMOVE Node.js

# DELETE these lines:
# RUN curl -sL https://deb.nodesource.com/setup_XX.x | bash -
# RUN apt-get install -y nodejs
# RUN npm install -g yarn

# DELETE Webpacker precompile:
# RUN bundle exec rails webpacker:compile

# KEEP only:
RUN bundle exec rails assets:precompile
```

#### Step 7: Update CI/CD

```yaml
# .github/workflows/ci.yml

# REMOVE Node.js setup
# - uses: actions/setup-node@v3

# REMOVE yarn install
# - run: yarn install

# REMOVE webpacker compile
# - run: bundle exec rails webpacker:compile

# KEEP only:
- run: bundle exec rails assets:precompile
```

#### Step 8: Clean Build Artifacts

```bash
bin/rails assets:clobber
RAILS_ENV=production bin/rails assets:precompile
ls -lah public/assets/  # Verify
```

**Verification Checklist**:
- [ ] No React code anywhere
- [ ] No webpack config
- [ ] No node_modules
- [ ] All pages render
- [ ] Assets precompile
- [ ] Docker builds
- [ ] CI passes

---

### Week 6: Testing & Turbo Native Setup

**Goal**: Comprehensive testing + mobile app foundation

#### A. Comprehensive Testing

**Manual Testing**:
- [ ] All pages render correctly
- [ ] All forms work
- [ ] Navigation works
- [ ] Back button works
- [ ] Mobile responsive
- [ ] Offline graceful degradation

**Browser Testing**:
- [ ] Chrome/Edge (latest)
- [ ] Firefox (latest)
- [ ] Safari (macOS & iOS)
- [ ] Chrome (Android)

**Performance Testing**:
```bash
# Use Chrome DevTools Lighthouse
# Target: Performance > 90
```

**Load Testing**:
```ruby
# spec/system/load_test.rb
RSpec.describe "Load testing", type: :system do
  it "handles 100 concurrent users" do
    threads = 100.times.map do
      Thread.new do
        visit root_path
        expect(page).to have_content("Nadchodzące wydarzenia")
      end
    end
    threads.each(&:join)
  end
end
```

#### B. Turbo Native Setup (iOS)

**Step 1: Create iOS Project**
```bash
# Use Xcode to create new project
# Or use Turbo Native template:
git clone https://github.com/hotwired/turbo-ios
```

**Step 2: Configure Base URL**
```swift
// SceneDelegate.swift
let rootURL = URL(string: "https://your-app.com")!
let session = Session()
let controller = VisitableViewController(url: rootURL)
```

**Step 3: Native Navigation**
```swift
// AppDelegate.swift
extension SceneDelegate: SessionDelegate {
    func session(_ session: Session, 
                 didProposeVisit proposal: VisitProposal) {
        // Handle navigation
        let viewController = VisitableViewController(url: proposal.url)
        navigationController.pushViewController(viewController, animated: true)
    }
}
```

**Step 4: Test in Simulator**
```bash
# Open in Xcode and run
open TurboNativeApp.xcodeproj
```

#### C. Turbo Native Setup (Android)

**Step 1: Create Android Project**
```bash
# Use Android Studio or Turbo Native template
git clone https://github.com/hotwired/turbo-android
```

**Step 2: Configure Base URL**
```kotlin
// MainActivity.kt
private const val BASE_URL = "https://your-app.com"

class MainActivity : AppCompatActivity(), TurboActivity {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        TurboSessionNavHostFragment.location = BASE_URL
    }
}
```

**Step 3: Test in Emulator**
```bash
# Open in Android Studio and run
./gradlew installDebug
```

#### D. Server-Side Detection

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  helper_method :turbo_native_app?
  
  private
  
  def turbo_native_app?
    request.user_agent.to_s.match?(/Turbo Native/)
  end
end
```

```slim
/ Use in views for native-specific UI
- if turbo_native_app?
  / Native-specific UI
- else
  / Web-specific UI
```

---

## 📊 Results & Metrics

### Expected Improvements

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| **JavaScript Bundle** | 500 KB | 10 KB | -98% |
| **Page Load (3G)** | 3.5s | 1.2s | -66% |
| **Time to Interactive** | 4.2s | 1.5s | -64% |
| **Build Time** | 45s | 2s | -96% |
| **Dependencies** | 200+ npm | 0 | -100% |
| **Docker Image** | 1.2 GB | 850 MB | -29% |
| **Lighthouse Score** | 65 | 95+ | +46% |

### Technical Wins

✅ **No build step** - assets served directly
✅ **No npm packages** - zero dependency hell
✅ **SEO perfect** - server-rendered HTML
✅ **Mobile ready** - Turbo Native compatible
✅ **Simpler stack** - easier to maintain
✅ **Faster CI/CD** - no webpack compilation

---

## 🎯 Key Principles

### 1. Server-Rendered First

```
React approach:     Server → JSON → Client renders
Rails 8 approach:   Server → HTML → Client displays
```

**Benefits**:
- Faster first paint
- Works without JS
- SEO-friendly
- Simpler debugging

### 2. Progressive Enhancement

```
Level 1: Works without JS
Level 2: Turbo Drive (faster navigation)
Level 3: Turbo Frames (partial updates)
Level 4: Stimulus (minimal interactions)
```

### 3. Mobile-First with Turbo Native

```
Web browser:    Just works
iOS app:        Turbo Native wrapper
Android app:    Turbo Native wrapper

Same codebase for all!
```

---

## ✅ Success Criteria

### Must Have
- [ ] All React components replaced
- [ ] Zero npm dependencies
- [ ] All tests passing
- [ ] Lighthouse score > 90
- [ ] Works in Turbo Native
- [ ] Production deployed

### Nice to Have
- [ ] iOS app in TestFlight
- [ ] Android app in internal testing
- [ ] Performance monitoring
- [ ] User feedback positive

---

## 🚨 Risk Management

### Risk 1: Complex User Interactions
**If**: Some feature needs complex JS
**Then**: Use Stimulus controller (small, targeted)

### Risk 2: Browser Compatibility
**If**: Old browser issues
**Then**: Graceful degradation (works without Turbo)

### Risk 3: Team Learning Curve
**Mitigation**: 
- Hotwire is simpler than React
- Documentation provided
- Pair programming

### Rollback Plan

**If things go wrong**:
```bash
# Option 1: Rollback deployment
kamal rollback

# Option 2: Git revert
git revert HEAD~N
kamal deploy

# Option 3: Feature flag
# Keep React temporarily for specific features
```

---

## 📚 Resources

### Official Documentation
- [Hotwire](https://hotwired.dev) - Main documentation
- [Turbo](https://turbo.hotwired.dev) - Turbo reference
- [Stimulus](https://stimulus.hotwired.dev) - Stimulus guide
- [Turbo Native iOS](https://github.com/hotwired/turbo-ios)
- [Turbo Native Android](https://github.com/hotwired/turbo-android)
- [Propshaft](https://github.com/rails/propshaft)

### Learning
- [Hotwire Handbook](https://hotwired.dev) - Interactive guide
- [Turbo Native Tutorial](https://masilotti.com/turbo-ios/) - iOS guide
- [Rails 8 Release Notes](https://edgeguides.rubyonrails.org/8_0_release_notes.html)

---

## 🎯 Next Steps

### Immediate (This Week)
1. **Review this plan** with team
2. **Get approval** from tech lead
3. **Create branch** `feature/remove-react`
4. **Schedule kickoff** meeting

### Week 1
1. Install Propshaft + Hotwire
2. Verify existing functionality
3. Test Turbo Drive acceleration

### Weeks 2-4
1. Migrate components one by one
2. Test thoroughly after each
3. Document learnings

### Weeks 5-6
1. Remove React/Webpacker
2. Comprehensive testing
3. Deploy to production
4. Set up Turbo Native

---

## 📝 Final Notes

### Philosophy

> "The best code is no code. The best build step is no build step. The best dependency is no dependency."

### Why This Works

1. **Rails strength**: Server-side rendering
2. **Hotwire magic**: Feels like SPA without complexity
3. **Turbo Native**: One codebase → 3 platforms (web + iOS + Android)
4. **Simplicity**: Easy to understand, easy to maintain

### The Future

With this foundation:
- Easy to add features (just HTML)
- Easy to build mobile apps (Turbo Native)
- Easy to maintain (no webpack config)
- Easy to onboard (simpler stack)

---

**Document Version**: 2.0  
**Last Updated**: 2025-01-XX  
**Status**: READY FOR IMPLEMENTATION  
**Owner**: Development Team

---

## Quick Reference: Cheat Sheet

### Turbo Frame (Partial Update)
```slim
= turbo_frame_tag "my_frame" do
  / Content that updates independently
```

### Turbo Stream (Multiple Updates)
```ruby
# Controller
render turbo_stream: [
  turbo_stream.update("id", partial: "x"),
  turbo_stream.append("id", partial: "y")
]
```

### Stimulus Controller (Minimal JS)
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]
  
  greet() {
    this.outputTarget.textContent = "Hello!"
  }
}
```

### Turbo Native Detection
```ruby
# Controller
def turbo_native_app?
  request.user_agent.to_s.match?(/Turbo Native/)
end
```

---

**END OF PLAN**