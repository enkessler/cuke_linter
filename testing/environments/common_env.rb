require 'require_all'

require 'cuke_linter'
require 'open3'


require_relative '../model_factory'
require_relative '../linter_factory'
require_relative '../formatter_factory'
require_relative '../file_helper'
require_relative '../helper_methods'

PROJECT_ROOT = "#{__dir__}/../..".freeze
MOST_CURRENT_CUKE_MODELER_VERSION = ENV['MOST_CURRENT_CUKE_MODELER_VERSION'].to_i
