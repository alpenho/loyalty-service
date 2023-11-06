ActiveRecord::Base.configurations = YAML.safe_load_file('config/database.yml', aliases: true)
ActiveRecord::Base.establish_connection(:development)

Dir['models/*.rb'].each { |file| require_relative file }

class LoyaltyServiceAPI < Sinatra::Base
  use Rack::JSONBodyParser

  get '/' do
    'Hello Worlds!'
  end
end
