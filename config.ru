require './app'
require './middlewares/happiness_backend'

use HappinessPoll::HappinessBackend

run HappinessPoll::App
