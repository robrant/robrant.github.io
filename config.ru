require 'rack/jekyll'

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  [username, password] == ['keeper', 'lighthouses are great']
end

run Rack::Jekyll.new
