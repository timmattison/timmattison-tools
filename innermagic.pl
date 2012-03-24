#!/usr/bin/perl -w

# innermagic.pl by Tim Mattison (tim@mattison.org)
# Version 0.1 - 2012-03-24

# Release history:
#   Version 0.1 - 2012-03-24 - First release
my $version = "0.1";
my $release_date = "2012-03-24";

# This script was written to make it easier to find files embedded in larger container
#   files.  This is particularly useful when reverse engineering an unknown or
#   undocumented file type.

# Use a 1MB buffer
my $BUFFER_MAX_SIZE = 1024 * 1024;

# And here comes the real code...

# Make sure we have the File::MMagic module
eval {
  require File::MMagic;
};

if($@) {
  die "The File::MMagic module is required but this system does not appear to have it";
}

# Get the input file
my $input_file = $ARGV[0];

# Find the "magic file"
if(-e "/etc/magic") {
  $magic_file = "/etc/magic";
}
elsif(-e "/usr/share/etc/magic") {
  $magic_file = "/usr/share/etc/magic";
}
else {
  die "Couldn't find a \"magic\" file";
}

# Create the file type object
my $file_type = File::MMagic->new($magic_file);

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

# Initialize the buffer position
$buffer_position = 0;

# Loop while there are still bytes available
while($bytes_read != 0) {
  # Convert the buffer to an array
    print "xxx: " . $file_type->checktype_contents($buffer) . "\n";
  @buffer = split //, $buffer;

  my $current_character;

  # Loop through all of the bytes of the current buffer
  while($buffer_position < $bytes_read) {
    print "Offset $buffer_position: " . $file_type->checktype_contents(substr($buffer, $buffer_position)) . "\n";

    # Move to the next buffer position
    $buffer_position++;
  }

  # Read the next buffer worth of data
  $bytes_read = sysread INPUT, $buffer, $BUFFER_MAX_SIZE;

  # Reset the buffer position
  $buffer_position = 0;

  # Make sure the read didn't fail
  check_failure($bytes_read);
}

exit;

sub check_failure {
  my $bytes_processed = $_[0];

  if(!defined($bytes_processed)) {
    die "No bytes processed: $!";
  }
}
