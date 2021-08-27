FROM ruby:2.7.3-alpine

ARG UID=1000
ADD vendor /app/vendor/

RUN addgroup -S app
RUN adduser -S -G app -u $UID app
RUN echo 'gem: --no-rdoc --no-ri' > ~/.gemrc && \
mkdir -p /app && \
apk add --update git build-base mysql-dev linux-headers yarn less nano tzdata bash openssh curl shared-mime-info && \
cd /app && ls && ls vendor

RUN cp /usr/share/mime/packages/freedesktop.org.xml ./ \
  && apk del -y --purge shared-mime-info \
  && mkdir -p /usr/share/mime/packages/ \
  && cp ./freedesktop.org.xml /usr/share/mime/packages/

WORKDIR /app

ADD Gemfile Gemfile.lock yarn.lock package.json /app/

RUN gem install bundler && bundle install

RUN yarn

RUN chown -R app /app && \
chgrp -R app /app

ENV RAILS_ENV development

# ADD --chown=app:app .rubocop.yml .rubocop_todo.yml
ADD --chown=app:app config.ru  .env.* Rakefile babel.config.js /app/

ADD --chown=app:app app /app/app
ADD --chown=app:app bin /app/bin
ADD --chown=app:app config /app/config
ADD --chown=app:app db /app/db
ADD --chown=app:app lib /app/lib
ADD --chown=app:app test /app/test
ADD --chown=app:app vendor /app/vendor

# Start the main process.
CMD ["sh", "-c", "rails s -p 52130 -b 0.0.0.0"]
