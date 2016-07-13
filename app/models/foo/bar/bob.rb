# Foo::Alice
# module Foo
#   module Bar
#     class Bob < Array
#       Alice.new.strip!    # NoMethodError: undefined method `strip!' for #<Foo::Alice:0x00556042031ab8>
#     end
#   end
# end

# module Foo
#   module Bar
#     class Bob < Array
#       Bar::Alice.new.strip!
#     end
#   end
# end

module Foo::Bar

    class Bob < Array
      Bar::Alice.new.strip!    # NameError: uninitialized constant Foo::Bar::Bob::Bar
    end

end

# module Foo
#   module Bar
#     class Bob < Array
#       class << self
#         Bob.push Alice.new    # NameError: uninitialized constant Alice
#       end
#     end
#   end
# end
