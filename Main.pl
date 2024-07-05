#!/usr/bin/perl
use strict;
use warnings;
use Tkx;
require "./Util.pl";
require "./Tank.pl";
require "./Obstacle.pl";
require "./Helicopter.pl";
require  "./Heliport.pl";

package Main;
my $mw = Tkx::widget->new(".");
$mw->g_wm_title("Helicopter Game");
my $bg_image = Tkx::image_create_photo(-file => "images/plan.png", -width => 800, -height => 800);
my $canvas = $mw->new_canvas(-width => 800, -height => 600, -background => "#ffffff");

$canvas->g_pack();
$canvas->create_image(400, 400, -image => $bg_image);
my @obstacles = Obstacle->getAll($canvas);
# push @obstacles, Obstacle->new($canvas, [100, 100, 200, 100, 200, 200, 100, 200]);
# push @obstacles, Obstacle->new($canvas, [500, 500, 600, 500, 600, 600, 500, 600]);

# my @heliports = Heliport->getAll($canvas);
my @heliports;
push @heliports, Heliport->new($canvas, 50, 400);
push @heliports, Heliport->new($canvas, 650, 200);

my $heli =  Helicopter->new($canvas,50,300);
my $heli1 = Helicopter->new($canvas,600,300);

my @tanks = Tank->getAll($canvas);

sub key_press {
    my ($key) = @_;
    if ($key eq 'Up') {
        $heli->{dy} = -3;
    } elsif ($key eq 'Right') {
        $heli->{dx} = 3;
    } elsif ($key eq 'Left') {
        $heli->{dx} = -3;
    }
}

sub key_release {
    my ($key) = @_;
    if ($key eq 'Up') {
        $heli->{dy} = 3; #Important
    } elsif ($key eq 'Right') {
        $heli->{dx} = 0;
    } elsif ($key eq 'Left') {
        $heli->{dx} = 0;
    }
    if($key eq 's') {
        $heli->save();
    }
    if($key eq 'Down') {
        $heli->bombarder();
        $heli1->bombarder();
    }
}

# Boucle ppl
sub game_loop {
    $heli->move(\@tanks, \@obstacles, \@heliports);
    $heli1->move(\@tanks, \@obstacles, \@heliports, $heli);
    foreach my $tank(@tanks) {
        $tank->move(\@obstacles);
    }
    Tkx::after(10, \&game_loop);
}
game_loop();

# Listner
$mw->g_bind("<KeyPress>", [\&key_press, Tkx::Ev("%K")]);
$mw->g_bind("<KeyRelease>", [\&key_release, Tkx::Ev("%K")]);

Tkx::MainLoop();