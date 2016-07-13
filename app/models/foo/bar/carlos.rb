module Foo
  module Bar::Carlos
    Alice    # Foo::Bar::Alice loaded

    Alice    # NameError: uninitialized constant Foo::Bar::Carlos::Alice
  end
end
