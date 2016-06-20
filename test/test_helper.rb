$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'Cthulhu'

require 'pry'
require 'database_cleaner'
require 'factory_girl'
require 'minitest/autorun'
require 'models'
require 'db_definition'
require 'active_support/testing/assertions'

FactoryGirl.definition_file_paths = [ 'test/factories' ]
FactoryGirl.find_definitions

db = URI.parse(ENV['DATABASE_URL'] || 'postgres://postgres@localhost/cthulhu_test')

ActiveRecord::Base.establish_connection(
  adapter: db.scheme == 'postgres' ? 'postgresql' : db.scheme,
  host: db.host,
  username: db.user,
  password: db.password,
  database: db.path[1..-1],
  encoding: 'utf8'
)

# ActiveRecord::Base.logger = Logger.new STDOUT

ActiveRecord::Base.connection.transaction do
  DbDefinition.new.exec_migration ActiveRecord::Base.connection, :up
end

DatabaseCleaner.strategy = :transaction

class Minitest::Spec

  include FactoryGirl::Syntax::Methods
  include ActiveSupport::Testing::Assertions

  before(:each) do
    DatabaseCleaner.start
  end

  after(:each) do
    DatabaseCleaner.clean
  end

end
