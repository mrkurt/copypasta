require 'compass'
require 'compass/app_integration/rails'
Compass::AppIntegration::Rails.initialize!

require "fileutils"
FileUtils.mkdir_p(Rails.root.join("tmp", "stylesheets", "compiled"))
