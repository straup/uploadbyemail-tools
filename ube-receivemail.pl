#!/usr/bin/env perl

use strict;
use warnings;

use Email::Simple;
use Email::MIME;

use File::Temp;
use FileHandle;

use constant MAX_BYTES => 4 * 1024 * 1024;

{
    &main();
    exit;
}

sub main {

        &wtf("running at " . time());

        my $email = &get_email();

        if (! $email) {
                &omgwtf("unable to get email");
                return 0;
        }
                
        my $parts = &get_parts($email);

        if (! $parts->{'images'}->[0]){
                &omgwtf("unable to get parts");
                return 0;
        }
        
        my $fname = &write_image($parts->{'images'}->[0]);
        
        if (! $fname) {
                &omgwtf("unable to write image");
                return 0;
        }

        my @args = &build_args($fname, $parts->{'subject'});

        print STDOUT join("|", @args);

        &wtf("finished at " . time());
        return 1;
}

sub build_args {
        my $fname   = shift;
        my $subject = shift;
        
        # -f p -t "{title}" -p 

        my %key = ("r" => "rockstr",
                   "p" => "postcrd",
                   "P" => "postr",
                   "d" => "dazd",
                   "f" => "filtr");
        
        my $filter = "postr";
        my $extra = "";

        my $title = "";
        my $perms = "";

        if ($subject =~ /^\.(r|f|p|d)/i) {
                my $which = $1;
                $filter = "$key{$which}";
        }

        elsif ($subject =~ /-f\s+(r|f|p|d|P)/){
                my $which = $1;
                $filter = $key{$which};
        }

        else {}

        if ($subject =~ /-t\s+\"([^\"]+)\"/){
                $title = $1;
        }
        
        if ($subject =~ /-p\s+(pub|pri|fr|fa|ff)/){
                $perms = $1;
        }

        if ($fname =~ /\.mp4$/) {
                $filter = "movr";
                $extra = $filter;
        }

        return ($fname, $filter, $extra, $title, $perms);
}

sub get_email {

        my $msg = "";
        
        while (<STDIN>) {
                $msg .= $_;
                
                do {
                        use bytes;
                        
                        if (length($msg) > MAX_BYTES) {
                                return undef;
                        }
                };
                
        }
        
        return Email::Simple->new($msg);
}

sub get_parts {
        my $email = shift;
        my $mime = Email::MIME->new($email->as_string());

        my %parts = ('images'  => [],
                     'subject' => $email->header("Subject"),
                     'body'    => undef);

        foreach my $part ($mime->parts()) {

                my $fname = $part->filename() || "fname-".time();

                &wtf("part: " . $fname . " / " . $part->content_type());

                if ($fname =~ /\.(?:jpg|mp4)$/) {
                        push @{$parts{'images'}}, $part;
                        next;
                }
                     
                if (($part->content_type() =~ /^text\/plain/) && (! $parts{'body'})){
                        $parts{'body'} = $part;
                        next;
                }
        }
        
        return \%parts;
}

sub write_image {
        my $image = shift;
        my $ext = ($image->filename() =~ /\.mp4$/) ? ".mp4" : ".jpg";

        my $fname = File::Temp->new(UNLINK=>0, SUFFIX=>$ext);
        return &write_part($fname, $image);
}

sub write_part {
        my $path = shift;
        my $part = shift;

        &wtf("writing $path");

        if (! open FH, ">$path") {
                &omgwtf("failed to open $path for writing, $!");
                return undef;
        }

        print FH $part->body();
        close FH;
        
        return $path;
}

sub omgwtf {
        my $txt = shift;
        &wtf($txt);
        warn $txt;
}

sub wtf {
        my $txt = shift;

        my $tmp = "/tmp/receive.pl.log";
        my $fh = FileHandle->new();
        $fh->open(">>$tmp");

        $fh->print("$txt\n");
        $fh->close();

        return 1;
}
