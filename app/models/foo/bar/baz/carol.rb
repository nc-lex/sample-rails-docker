module Foo
  module Bar::Baz
    class Carol
      Alice.new.strip!    # Foo::Bar::Alice loaded

      Alice.new.strip!    # NameError: uninitialized constant Foo::Bar::Baz::Carol::Alice
    end
  end
end
