# Redirects STDOUT to `Thread.current[:stdout]` if present
$stdout.instance_eval do
  alias :original_write :write
end

$stdout.define_singleton_method(:write) do |value|
  if Thread.current[:stdout]
    Thread.current[:stdout].write value
  else
    original_write value
  end
end
