package com.timmattison.tools;

import org.apache.commons.codec.binary.Hex;
import org.apache.commons.io.IOUtils;

import java.io.File;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * Created by timmattison on 8/13/14.
 */
public class DirHash {
    private static String basePathName;

    public static void main(String[] args) throws NoSuchAlgorithmException, IOException {
        if ((args == null) || (args.length != 1)) {
            System.out.println("Specify one, and only one, directory to hash");
            System.exit(1);
        }

        basePathName = args[0];
        basePathName = basePathName.replace("~", System.getProperty("user.home"));

        File basePath = new File(basePathName);
        basePathName = basePath.getAbsolutePath();

        byte[] hash = hash(basePathName);

        String hexString = new String(Hex.encodeHex(hash));

        System.out.println(hexString + " " + basePathName);
    }

    private static byte[] hash(String filename) throws NoSuchAlgorithmException, IOException {
        MessageDigest messageDigest = MessageDigest.getInstance("SHA-1");

        if (isDirectory(filename)) {
            File directory = new File(filename);

            // TODO: Get all of the directory entries
            List<File> files = new ArrayList<File>(Arrays.asList(directory.listFiles()));

            // TODO: Sort them
            Collections.sort(files);

            for (File file : files) {
                // TODO: Hash each file in order with its name appended to it
                messageDigest.update(hash(file.getAbsolutePath()));
            }
        } else {
            messageDigest.update(IOUtils.toByteArray(new File(filename).toURI()));
            String shortPath = filename.substring(basePathName.length());
            messageDigest.update(shortPath.getBytes());
        }

        return messageDigest.digest();
    }

    private static boolean isDirectory(String filename) {
        File file = new File(filename);
        return file.isDirectory();
    }

    /*

sub dirhash {
  my $source = $_[0];
  my $base_path = $_[1];

  # Is the source a directory?
  if(-d $source) {
    # Yes, process it recursively
    opendir SOURCE_DIRECTORY, $source;

    my @source_list;

    # Build a list of the entries in this directory
    while(readdir SOURCE_DIRECTORY) {
      my $directory_entry = $_;

      # Is this entry safe?
      if(($directory_entry ne ".") && ($directory_entry ne "..")) {
        # Yes, add it to the list
        push(@source_list, $source . "/" . $_);
      }
    }

    # Sort the list
    @source_list = sort(@source_list);

    # Create a destination for our master result
    my $result = "";

    # Hash each element individually
    foreach my $inner_source (@source_list) {
      $result .= dirhash($inner_source, $source);
    }

    # Hash the result itself
    $result = hash_string($result);

    # Return so we don't run this code on a raw directory
    return $result;
  }

  # This is a file, not a directory so the input file is the source
  my $input_file = $source;

  return hash_file($input_file, $base_path);
}

sub hash_string {
  my $input_string = $_[0];

  return hash($input_string, 0);
}

sub hash_file {
  my $input_file = $_[0];
  my $base_path = $_[1];

  return hash($input_file, 1, $base_path);
}

sub hash {
  my $input_data = $_[0];
  my $is_file = $_[1];
  my $base_path = $_[2];

  # Create a new instance of the SHA-512 algorithm object
  my $sha = Digest::SHA->new("SHA-512");

  # Is this a file?
  if($is_file == 1) {
    # Yes, add the specified file to it
    $sha->addfile($input_data);

    my $hash_file = $input_data;

    # Is there a base path?
    if(defined($base_path)) {
      # Yes, remove it so that we get consistent results when the files are
      #   in different paths
      $hash_file = substr($input_data, length($base_path));
    }

    # Add the filename onto the end of the data to be hashed
    $sha->add(" " . $hash_file);
  }
  else {
    # No, hash the data as a string
    $sha->add($input_data);
  }

  # Return the base 64 digest
  return $sha->b64digest;
}

sub show_usage {
  print "Usage: PROGRAM DIRECTORY_1 DIRECTORY_2 ...\n";
  print "\n";
  exit;
}

     */
}
