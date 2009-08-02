#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Std;
use Config::Simple;

use Net::Flickr::API;
use Image::Info qw (image_info);

{
        &main();
        exit;
}

sub main {

        my %opts = ();
        getopts('c:i:p:t:s:P:T:e:', \%opts);
        
        my $cfg = Config::Simple->new($opts{'c'});
        my $fl = Net::Flickr::API->new($cfg);

        my $image = $opts{'i'};
 
        if (! defined($image)){
                return 0;
        }
        
        if (! -f $image){
                warn "not a valid image file";
                return 0;
        }

        my $tags = $cfg->param("uploadbyemail.tags") || '';
        my $set_id = $cfg->param("uploadbyemail.add_to_set") || 0;

        if ($opts{'s'}){
                $set_id = $opts{'s'};
        }

        if ($opts{'t'}){
                $tags .= " $opts{'t'}";
        }

        my $title = "Untitled #" . time();

        if ($opts{'T'}){
                $title = $opts{'T'};
        }
        
        if ($opts{'p'}) {
                $tags .= " filtr:process=" . $opts{'p'};
        }

        my $friend = $cfg->param("uploadbyemail.is_friend") || 0;
        my $family = $cfg->param("uploadbyemail.is_family") || 0;
        my $public = $cfg->param("uploadbyemail.is_public") || 0;

        if (my $priv = $opts{'P'}){

                if ($priv eq 'pub'){
                        $public = 1;
                }

                elsif ($priv eq 'fr'){
                        $public = 0;
                        $friend = 1;
                        $family = 0;
                }

                elsif ($priv eq 'fa'){
                        $public = 0;
                        $friend = 0;
                        $family = 1;
                }

                elsif ($priv eq 'ff'){
                        $public = 0;
                        $friend = 1;
                        $family = 1;
                }

                else {}
        }

        $fl->log()->info("post: $image");
        $fl->log()->info("title: $title");
        $fl->log()->info("tags: $tags");
        $fl->log()->info("set: $set_id");
        $fl->log()->info("privacy public:$public friend:$friend family:$family");

        # 

        my $has_gps = 0;

        eval {
                my $info = image_info($image);
                
                if (($info) && ($info->{'Model'})){
                        $tags .= " ph:camera=" . lc($info->{'Model'});
                }

                if (($info) && (ref($info->{'GPSLatitude'}))){
                    $has_gps = 1;
                }
        };
        
        #

        my %args = (
                    'photo'      => $image,
                    'title'      => $title,
                    'description' => '',
                    'tags'       => $tags,
                    'is_public'  => $public,
                    'is_friend'  => $friend,
                    'is_family'  => $family,
                   );

	my $id = $fl->upload(\%args);

        $fl->log()->info("post returned ID: $id");

        if (! $id){
                return 0;
        }

	# add to set?

        if ($set_id){
                
                my $res = $fl->api_call({'method' => 'flickr.photosets.addPhoto',
                                         'args' => {photoset_id => $set_id,
                                                    photo_id => $id}});

        }
        
        # send to twitter? fails with 'photo not found' errors...

        if (0){

                $fl->api_call({'method' => 'flickr.blogs.postPhoto',
                               'args' => {'service' => 'twitter',
                                          'photo_id' => $id,
                                          'title' => 'testing'}});
        }

        # happy, go home
 
        print STDOUT $id;
        return $id;
}
