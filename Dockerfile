FROM ruby:3.0.0-slim

ARG RAILS_ENV=development
ENV BUNDLER_VERSION=2.2.28

RUN apt-get update -qq && apt-get install -qq --no-install-recommends \
    curl \
    gnupg2

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -\
  && apt-get update -qq && apt-get install -qq --no-install-recommends \
    nodejs build-essential libpq-dev \
  && apt-get upgrade -qq \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*\
  && npm install -g yarn@1

RUN addgroup --system app && adduser --system --ingroup app app

WORKDIR /opt/app

COPY --chown=app:app Gemfile* package.json yarn.lock /opt/app/
RUN chown -R app:app /opt/app

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

USER app
RUN gem install bundler -v $BUNDLER_VERSION
RUN yarn install
RUN bundle install

COPY --chown=app:app . /opt/app

ENTRYPOINT ["entrypoint.sh"]
