# Borrowed from active support.
# Ruby 1.9 introduces an inherit argument for Module#const_get and
# #const_defined? and changes their default behavior.

class String
  def constantize #:nodoc:
    names = self.split('::')
    names.shift if names.empty? || names.first.empty?

    constant = Object
    names.each do |name|
      constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
    end
    constant
  end

  def self.random_string(len = 8)
    ar = 'abcdefgijhklmnopqrstwxyz0123456789'.split('')
    str = ''
    len.times { str << ar[rand(ar.size)]}
    str
  end

end

