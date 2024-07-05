use strict;
use warnings;
use Tkx;
require "./Util.pl";
package Heliport;

sub new {
    my ($class, $canvas, $x, $y) = @_;
    my $self = {
        canvas => $canvas,
        image  => Tkx::image_create_photo(-file => "images/landing.png", -width => 80, -height => 80),
        width => 80,
        height => 80,
        x => $x,
        y => $y,
    };

    bless $self, $class;
    $self->draw();
    return $self;
}

sub draw {
    my ($self) = @_;
    print $self->{x},$self->{y},"\n";
    # $self->{id} = $self->{canvas}->create_rectangle($self->toRect(), -fill =>"#ffffff", -outline => 'red');
    $self->{idImage} = $self->{canvas}->create_image($self->{x}, $self->{y}, -image => $self->{image});
}

sub toRect {
    my ($self) = @_;
    my $hw = ($self->{width} / 2);
    my $hh = ($self->{height} / 2);
    my @tank_rect = ($self->{x} - $hw, $self->{y} - $hh, $self->{x} + $hw, $self->{y} + $hh);

    return @tank_rect;
}

sub getAll {
    my ($self, $canvas) = @_;
    my $dbh = Util->getDBH();
    my $query = "SELECT * FROM heliport";
    my $sth = $dbh->prepare($query);
    $sth->execute();
    my @heliports;
    while (my $row = $sth->fetchrow_hashref) {
        push @heliports, Heliport->new($canvas, $row->{x}, $row->{y});
    }
    $dbh->disconnect;
    return @heliports;
}
1;