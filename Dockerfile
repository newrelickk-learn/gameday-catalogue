FROM ruby:3.1.6

# Install Node.js and Yarn using NodeSource repository (more reliable)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - &&\
    apt-get install -y nodejs &&\
    npm install -g yarn

ENV NODE_OPTIONS=--openssl-legacy-provider
# throw errors if Gemfile has been modified since Gemfile.lock
RUN useradd -u 1000 -m -s /bin/bash appuser
USER 1000
RUN gem uninstall bundler
RUN gem install bundler --version '2.6.2'
RUN bundle config --global frozen 1

RUN mkdir /home/appuser/webapp

WORKDIR /home/appuser/webapp

COPY ./app ./app
COPY ./bin ./bin
COPY ./vendor ./vendor
COPY ./config ./config
COPY ./db ./db
COPY ./lib ./lib
COPY ./public ./public
COPY ./storage ./storage
COPY ./config.ru ./
COPY ./babel.config.js ./
COPY ./.browserslistrc ./
COPY ./.ruby-version ./
COPY ./Rakefile ./
COPY ./package.json ./
COPY ./yarn.lock ./

COPY Gemfile Gemfile.lock ./
RUN mkdir -p tmp/pids

USER root
RUN gem update --system
RUN chmod 644 config/master.key
RUN chown -R appuser:appuser /home/appuser/webapp
USER 1000
# Add current platform if needed (for local development)
RUN if [ "$(uname -m)" = "aarch64" ]; then bundle lock --add-platform aarch64-linux; fi
RUN bundle install
RUN bundle exec rails assets:precompile RAILS_ENV=production
ARG COMMIT_SHA="sha"
ARG RELEASE_TAG="dev"
ENV NEW_RELIC_METADATA_COMMIT=$COMMIT_SHA
ENV NEW_RELIC_METADATA_HOGE=fuga
ENV NEW_RELIC_METADATA_RELEASE_TAG=$RELEASE_TAG
ENV NEW_RELIC_CODE_LEVEL_METRICS_ENABLED=true
ENV NEW_RELIC_RULES_IGNORE_URL_REGEXES="health"

CMD ["rails", "server", "--environment", "production"]
