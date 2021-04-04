require 'require_all'

require 'cuke_linter'
require 'open3'


require_relative '../model_factory'
require_relative '../linter_factory'
require_relative '../formatter_factory'
require_relative '../file_helper'

PROJECT_ROOT = "#{__dir__}/../..".freeze
