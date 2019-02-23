SimpleCov.start do
  root __dir__

  add_filter '/testing/'
  add_filter '/environments/'

  merge_timeout 300
end
