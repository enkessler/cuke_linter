SimpleCov.start do
  root __dir__

  add_filter '/testing/'

  merge_timeout 300
end
