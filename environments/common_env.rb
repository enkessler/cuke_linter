require 'require_all'

require 'cuke_linter'
require 'open3'


require_relative '../testing/model_factory'
require_relative '../testing/linter_factory'
require_relative '../testing/formatter_factory'
require_relative '../testing/file_helper'

PROJECT_ROOT = "#{__dir__}/.."
