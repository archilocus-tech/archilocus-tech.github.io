FROM ruby:3.3.10

WORKDIR /site

ENV BUNDLE_PATH=/usr/local/bundle

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 4000

ENTRYPOINT ["/entrypoint.sh"]
