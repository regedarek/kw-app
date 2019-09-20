FROM ruby:2.6.3-alpine

RUN apk update
RUN apk upgrade
RUN apk add --update build-base nodejs postgresql-dev tzdata git imagemagick libxml2-dev curl-dev

ENV app /usr/src/kw-app/
RUN mkdir $app
WORKDIR $app

ENV BUNDLER_VERSION 2.0.2
ENV BUNDLE_PATH /kw-app-gems

RUN gem install bundler
RUN bundle config --global github.https true

ADD . $app

EXPOSE 3002

CMD rm -f tmp/pids/server.pid && bundle exec rails s -p 3002 -b 0.0.0.0
