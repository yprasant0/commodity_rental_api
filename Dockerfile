FROM ruby:3.3.2

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
WORKDIR /rental_solution
COPY Gemfile /rental_solution/Gemfile
COPY Gemfile.lock /rental_solution/Gemfile.lock
RUN bundle install
COPY . /rental_solution

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
