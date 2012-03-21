#!/usr/bin/perl -w

# DO NOT USE!  This needs serious work before it is ready for prime time.
#
# Just from a performance point of view strings can do 2 GB in 32 seconds on my desktop
# (62.5 MB / sec) and strands can only do 635 MB in 609 seconds (1.04 MB / sec).

# strands.pl by Tim Mattison (tim@mattison.org)
# Version 0.1 - 2012-03-21

# Release history:
#   Version 0.1  - 2012-03-21 - First release
my $version = "0.1";
my $release_date = "2012-03-21";

# This script was written to supplement the Unix/Linux "strings" program.  strings is a
#   program that "prints the printable character sequences that are at least 4
#   characters long (or the number given with the options below)".  strands considers
#   more characters printable than strings does.  In particular, line termination
#   characters are considered non-printable by strings but considered printable by
#   strands.
#
# These additional characters are very helpful when trying to find blocks of source code
#   in disk images.  I wrote this utility because recently I was in a situation where I
#   needed to rescue some deleted source code from a virtual machine.  strings did a
#   great job finding that source code but left some holes in it.  strands made sure I
#   got all of the code without having to recreate portions of it myself.  In my case
#   strings always missed the tail end of Java functions which made blocks of code run
#   together.  This because many Java functions end like this:
#
#   START CODE BLOCK
#        e.printStackTrace();
#      }
#
#      return result;
#   }
#
#   private void otherMethod(String arg0) {
#      System.out.println(arg0);
#   }
#   END CODE BLOCK
#
#   With strings this would now look like this:
#
#   START STRINGS CODE BLOCK
#        e.printStackTrace();
#      return result;
#   private void otherMethod(String arg0) {
#      System.out.println(arg0);
#   END STRINGS CODE BLOCK
#   
#   Not too bad, but not perfect.  With strands it looks exactly as you'd want it to
#   without any additional work.

# Use a 1MB buffer
my $BUFFER_MAX_SIZE = 1024 * 1024;

# Require 4 characters to consider this a strand
my $CHARACTERS_REQUIRED = 4;

# And here comes the real code...

# Get the input file
my $input_file = $ARGV[0];

# Is there an input file specified?
if(!defined($input_file)) {
  # No, read from STDIN
  open(INPUT, "-");
}
else {
  # Yes, does it exist?
  if(!-e $input_file) {
    # No, tell them and die
    die "$input_file does not exist";
  }
  else {
    # Yes, open it
    open(INPUT, "<$input_file");
  }
}

# Read the first buffer worth of data
my $bytes_read = sysread INPUT, $buffer, $BUFFER_MAX_SIZE;

# Make sure the read didn't fail
check_failure($bytes_read);

# Initialize the strand length counter
my $strand_length = 0;

# Initialize the strand buffer
my $strand_buffer = "";

# Initialize the buffer position variable
my $buffer_position = 0;

my $counter = 0;
# Loop while there are still bytes available
while($bytes_read != 0) {
  # Convert the buffer to an array
  @buffer = split //, $buffer;

  my $current_character;

  # Loop through all of the bytes of the current buffer
  while($buffer_position < $bytes_read) {
    $current_character = $buffer[$buffer_position];

    # Check the current buffer position to see if we consider it printable
    if((ord($current_character) & 0x80) == 0x00) {
      # Yes, it is printable since it isn't upper ASCII

      # Increment the strand length
      $strand_length++;

      # Do we have enough characters to print?
      if($strand_length < $CHARACTERS_REQUIRED) {
        # No, just add it to the strand buffer and increment the strand length
        $strand_buffer .= $current_character;
      }
      else {
        # Did we just get enough characters to print?
        print_buffer_if_necessary($strand_length, $strand_buffer);

        # Print the new character
#        print $current_character;
      }
    }
    else {
      # No, it is not printable.  Were we just printing?
      if($strand_length >= $CHARACTERS_REQUIRED) {
        # Yes, print a newline
#        print "\n";

        # Reset the strand and its length
        $strand_buffer = "";
        $strand_length = 0;
      }
    }

    # Move to the next buffer position
    $buffer_position++;
  }

print "$counter MB\n";
$counter++;
  # Read the next buffer worth of data
  $bytes_read = sysread INPUT, $buffer, $BUFFER_MAX_SIZE;

  # Reset the buffer position
  $buffer_position = 0;

  # Make sure the read didn't fail
  check_failure($bytes_read);
}

# Last check to see if we have any characters to print
print_buffer_if_necessary($strand_length, $strand_buffer);

exit;

sub check_failure {
  my $bytes_processed = $_[0];

  if(!defined($bytes_processed)) {
    die "No bytes processed: $!";
  }
}

sub print_buffer_if_necessary {
  my $strand_length = $_[0];
  my $strand_buffer = $_[1];

  if($strand_length == $CHARACTERS_REQUIRED) {
    # Yes, print the strand buffer
    print $strand_buffer;
  }
}
