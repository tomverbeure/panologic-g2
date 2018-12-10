#! /usr/bin/env ruby

require 'optparse'
require 'pp'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: create_mif.rb [options]"
    opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options[:verbose] = v
    end

    opts.on("-fFORMAT", "--format=FORMAT", "Specify output format ('mif', 'hex', 'coe', 'mem')") do |f|
        options[:format] = f
    end

    opts.on("-dDEPTH", "--depth=DEPTH", Integer, "Memory depth") do |d|
        options[:depth] = d
    end

    opts.on("-wWIDTH", "--width=WIDTH", Integer, "Memory width (bits)") do |w|
        options[:width] = w
    end

    opts.on("-oOFFSET", "--offset=OFFSET", Integer, "First byte to use of the binary input file (default = 0)") do |o|
        options[:offset] = o
    end

    opts.on("-iINCREMENT", "--increment=INCREMENT", Integer, "How many bytes to the next byte (default = 1)") do |i|
        options[:increment] = i
    end

end.parse!

start_offset    = options[:offset]    || 0
increment       = options[:increment] || 1

bin = File.open(ARGV[0], "rb").read
bytes = bin.unpack("C*")[start_offset..-1].each_slice(increment).collect{ |a| a.first }

depth           = options[:depth]   || bytes.size
width           = options[:width]   || 8
format          = options[:format]  || "mif"

bytes_per_word = (width+7)>>3
nr_addr_bits = Math.log2(depth).ceil

if options[:verbose]
    STDERR.puts "output format : #{format}"
    STDERR.puts "depth         : #{depth}"
    STDERR.puts "width         : #{width}"
    STDERR.puts "bytes per word: #{bytes_per_word}"
    STDERR.puts "start offset  : #{start_offset}"
    STDERR.puts "increment     : #{increment}"
end

if format == "mif"
    puts %{-- Created by create_mif.rb
DEPTH         = #{depth};
WIDTH         = #{width};
ADDRESS_RADIX = HEX;
DATA_RADIX    = HEX;
CONTENT
BEGIN
    }

    addr_fmt_string = "%%0%dx" % ((nr_addr_bits+3)>>2)
    data_fmt_string = "%%0%dx" % (bytes_per_word * 2)

    fmt_string = "#{addr_fmt_string}: #{data_fmt_string};"

    words = bytes.each_slice(bytes_per_word)
    words.each_with_index do |w, addr|
        value = 0
        w.reverse.collect { |b| value = value * 256 + b }
        puts fmt_string % [addr, value]
    end

    if words.size < depth
        puts "[#{addr_fmt_string}..#{addr_fmt_string}]: #{data_fmt_string};" % [ words.size, depth-1, 0 ]
    end

    puts "END;"
    puts

elsif format == "coe"
    puts %{; Created by create_mif.rb
; block memory configuration:
; DEPTH         = #{depth};
; WIDTH         = #{width};
memory_initialization_radix=16;
memory_initialization_vector=}

    words = bytes.each_slice(bytes_per_word).collect do |w|
        value = 0
        w.reverse.collect { |b| value = value * 256 + b }
        value
    end

    (depth - words.size).times { words << 0 }
    data_fmt_string = "%%0%dx" % (bytes_per_word * 2)
    str = words.collect{ |w| data_fmt_string % w }.join(",\n") + ";"

    puts str

elsif format == "hex"

    words = bytes.each_slice(bytes_per_word).collect do |w|
        value = 0
        w.reverse.collect { |b| value = value * 256 + b }
        value
    end

    (depth - words.size).times { words << 0 }

    data_fmt_string = "%%0%dx" % (bytes_per_word * 2)
    str = words.collect{ |w| data_fmt_string % w }.join("\n")

    puts str

elsif format == "mem"

    words = bytes.each_slice(bytes_per_word).collect do |w|
        value = 0
        w.reverse.collect { |b| value = value * 256 + b }
        value
    end

    (depth - words.size).times { words << 0 }

    data_fmt_string = "%%0%dx" % (bytes_per_word * 2)
    str = words.collect{ |w| data_fmt_string % w }.join("\n")

    puts "@00000000"
    puts str

else
    Kernel.abort("Unknown format '#{format}'! Aborting...")
end
