misfit
======

Flexible approach to handling exceptions in ruby (for library writers, or consumers).  Inspired by [Avdi Grim](http://avdi.org/)'s excellent book [Exceptional Ruby](http://exceptionalruby.com/).

This was developed by [Ian White](http://github.com/ianwhite) while working at [Distinctive Doors](http://distinctivedoors.co.uk) who have kindly agreed to release this under the MIT-LICENSE.

Misfit allows any module to act like a ruby exception class and gives the ability to decorate any standard ruby exception, optionally adding data.

Misfit also provides a mechanism to change the error handling policy from raising to something else

Why?
----

For a library writer, this means your library can raise exceptions that will all be caught by 'rescue YourLib::Error',
but also specific exceptions can be rescued (like rescuing IOErrors, for example) by client code.

    # Your lib
    module YourLib
      module Error
        include Misfit
      end
      
      def self.do_some_work
        Error.wrap { some_calls_that_might_raise_errors_like_io_error }
        if no_good then raise Error, "It's no good"
      end
    end
    
    # Consumer of your lib can do this:
    begin
      YourLib.do_some_work
    rescue YourLib::Error
      log 'YourLib just errored'
    end
    
    # But they can also rescue specific errors they are interested in, say an IOError
    begin
      YourLib.do_some_work
    rescue IOError
      # open some tubes and retry
    rescue YourLib::Error => e
      # e is some non IOError raised by YourLib
    end

For a library consumer, you can write a simple wrapper to isolate a library that raises all manner of errors (perhaps undocumented)

    module ErrorByOtherLib
      include Misfit
    end
    
    def call_out_to_other_lib
      ErrorByOtherLib.wrap { OtherLib.so_some_stuff }
    end
    
`call_out_to_other_lib` will now raise errors that are `ErrorByOtherLib` as well as retaining their original identity (so an IOError can still be
rescued, but you can now rescue all errors raised by OtherLib).

Quacks like an exception
------------------------

When you create a misfit exception module, it can be used as if it was an exception class.  For example (the `YourLib:Error` example above)

    raise YourLib::Error, "an error"
    raise YourLib::Error.new("an error")
    YourLib::Error.exception(<message>, <backtrace>)
    
all work as if `YourLib::Error` was a ruby Exception class.

Niceties
--------

You can set the default basic Ruby exception class, and you can set up the equivalent of an inheritance hierarchy by simply including from the parent Exception:

    module YourLib
      module Error
        include Misfit
      end
      
      module NotFoundError
        include Error
        exception_class IndexError
      end
    end
    
`raise YourLib::NotFoundError` will be rescued by `YourLib::NotFoundError`, `YourLib::Error`, and `IndexError`

You can also optionally wrap and add data to any Error:

    e = YourLib::Error.wrap RuntimeError.new("Bad stuff"), {some: 'data'}
    e.is_a?(RuntimeError)   # => true
    e.is_a?(YourLib::Error) # => true
    e.data                  # => {some: 'data'}

`YourLib::Error.wrap &block` causes all raised exceptions to be wrapped as `YourLib::Error`

Other Examples of use:
----------------------

    module MyError
      include Misfit
    end

    raise MyError, "foo"
    # the above will be rescued as a StandardError, and a MyError

    raise MyError.wrap ArgumentError.new('Bad args')
    # the above will be rescued as an ArgumentError, and a MyError

    MyError.wrap do
      # some stuff that might raise errors
    end
    # any errors raised will also be MyErrors
  
    Adding data to exceptions

    MyError.new 'foo', {some: data}
    # this will be a MyError with #data => {some: data}

    MyError.wrap exception, {some: data}
    # the resulting exception will be a MyError, and have #data attribute of {some: data}

    # set up an error that has a different class as its base (like IOError for example)
    module MyIOError
      include MyError
      exception_class IOError
    end

    # the resulting error will be an IOError, extended with MyIOError, and MyError, and will be rescued as such
    raise MyIOError