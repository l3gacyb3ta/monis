# Copyright (c) 2018 Christian Huxtable <chris@huxtable.ca>.
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

module FrontMatter
  # Parses the `IO` given as *io*. Yields the frontmatter as a `String` and the
  # `IO` positioned at the start of the content to the given block. If
  # the contents leading newlines are desired setting *skip_newlines* to `false`
  # will prevent it from being skipped. By defualt the resultant front matter
  # string will be chomp'ed. To prevent this add the arguement `chomp: false`.
  #
  # Note: The provided `IO` must support `#.seek`.
  def self.parse(io : IO, skip_newlines : Bool = true, strip : Bool = true, &block : String, IO -> Nil) : Nil
    expect_sequence(io, "---\n")
    front = IO::Memory.new

    while (char = next_char(io))
      front << char
      next if (char != '\n')
      next if (!test_sequence(io, "---\n"))

      break
    end

    raise MalformedError.eof if (next_char(io).nil?)
    io.seek(-1, IO::Seek::Current)

    skip_newlines(io) if (skip_newlines)
    front = front.to_s
    front = front.strip if (strip)
    yield(front, io)
  end

  # Opens the file named by filename. Yields the frontmatter as a `String` and the
  # file descriptor positioned at the start of the content to the given block. If
  # the contents leading newlines are desired setting *skip_newlines* to `false`
  # will prevent it from being skipped. By defualt the resultant front matter
  # string will be stripped. To prevent this add the arguement `strip: false`.
  def self.open(filename : String, skip_newlines : Bool = true, strip : Bool = true, &block : String, IO::FileDescriptor -> Nil) : Nil
    File.open(filename, "r") { |fd|
      parse(fd, skip_newlines, strip: strip) { |fm, _fd_n| yield(fm, fd) }
    }
  end

  # Parses the `String` given as *string*. Yields the frontmatter as a `String`
  # and the remaineder as a `String` to the given block. If the contents leading
  # newlines are desired setting *skip_newlines* to `false` will prevent it
  # from being skipped. By defualt the resultant front matter string will be
  # stripped. To prevent this add the arguement `strip: false`.
  #
  # Note: This should not be used in most cases. It converts between `String`
  # and `IO::Memory` numerous times and is only included to make testing easier.
  def self.parse(string : String, skip_newlines : Bool = true, strip : Bool = true, &block : String, String -> Nil) : Nil
    io = IO::Memory.new(string)
    parse(io, skip_newlines, strip: strip) { |fm, fd| yield(fm, fd.gets_to_end) }
  end

  # :nodoc:
  private def self.next_char(input : IO) : Char?
    char = input.read_char
    return nil if (char.nil? || char == Char::ZERO)
    char
  end

  # :nodoc:
  private def self.expect_sequence(input : IO, expected : String) : Nil
    expected.each_char() { |expect|
      char = next_char(input)
      next if (char && char == expect)
      raise MalformedError.expected(expect, char)
    }
  end

  # :nodoc:
  private def self.test_sequence(input : IO, expected : String) : Bool
    count = 0
    expected.each_char() { |expect|
      char = next_char(input)
      count += 1
      next if (char == expect)
      input.seek(-count, IO::Seek::Current)
      return false
    }

    true
  end

  # :nodoc:
  private def self.skip_newlines(io : IO) : Nil
    char = '\0'
    while ((char = next_char(io)) && char == '\n')
    end

    io.seek(-1, IO::Seek::Current) if (char != '\n' && char != '\0' && !char.nil?)
  end

  class MalformedError < Exception
    # :nodoc:
    def self.expected(expected, was)
      new("Malformed Frontmatter - expected: #{expected.inspect}, was: #{was.inspect}.")
    end

    # :nodoc:
    def self.eof
      new("Malformed Frontmatter - expected more, was: EOF.")
    end
  end
end
