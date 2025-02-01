FROM bitnami/ruby:latest

WORKDIR /app

COPY . .
RUN bundle install

ARG COMMIT="(not set)"
ARG LASTMOD="(not set)"
ENV COMMIT=$COMMIT
ENV LASTMOD=$LASTMOD

EXPOSE 4567
CMD ["ruby", "./regexplanet.rb"]

