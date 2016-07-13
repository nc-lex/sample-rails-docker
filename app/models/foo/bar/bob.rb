# Foo::Alice
# module Foo
#   module Bar
#     class Bob
#       Alice.new << 'Bob'    # NoMethodError: undefined method `<<' for #<Foo::Alice:0x0055771a700aa8>
#     end
#   end
# end

# module Foo
#   module Bar
#     class Bob
#       Bar::Alice.new << 'Bob'
#     end
#   end
# end

# module Foo::Bar
#
#     class Bob
#       Bar::Alice.new << 'Bob'    # NameError: uninitialized constant Foo::Bar::Bob::Bar
#     end
#
# end

# module Foo
#   module Bar
#     class Bob
#       class << self
#         Alice.new << 'Bob'    # NameError: uninitialized constant Alice
#       end
#     end
#   end
# end
