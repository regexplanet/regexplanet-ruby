FROM cgr.dev/chainguard/ruby:latest-dev as builder

ENV GEM_HOME=/work/vendor
ENV GEM_PATH=${GEM_PATH}:/work/vendor
COPY Gemfile /work/
#COPY Gemfile.lock /work/
RUN gem install bundler && bundle install

FROM cgr.dev/chainguard/ruby:latest

ENV GEM_HOME=/work/vendor
ENV GEM_PATH=${GEM_PATH}:/work/vendor

COPY --from=builder /work/ /work/

ARG COMMIT="(not set)"
ARG LASTMOD="(not set)"
ENV COMMIT=$COMMIT
ENV LASTMOD=$LASTMOD

WORKDIR /work
COPY . .

ENTRYPOINT [ "ruby", "./regexplanet.rb" ]