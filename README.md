## Getting started

### Prerequisites

Docker-compose

### First build

Within terminal:
```docker-compose build
docker-compose run web bundle exec rake db:create
docker-compose run web bundle exec rake db:migrate
docker-compose run web bundle exec rake db:seed
docker-compose run web yarn install
docker-compose up
```

Go to [localhost:3002](http://localhost:3002). Enjoy!

### Development

Web (panel) [localhost:3002](http://localhost:3002)

MailCatcher (mail debugging tool) [localhost:1080](http://localhost:1080)

Sidekiq (queue) [localhost:3002/sidekiq](http://localhost:3002/sidekiq)


###

[![Code Climate](https://codeclimate.com/github/regedarek/kw-app.svg)](https://codeclimate.com/github/regedarek/kw-app)
[![Security](https://hakiri.io/github/regedarek/kw-app/master.svg)](https://hakiri.io/github/regedarek/kw-app/master)
[![Staging](https://kw-app-staging.herokuapp.com)](https://kw-app-staging.herokuapp.com)
