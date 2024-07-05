use strict;
use warnings;
require "./Util.pl";
package Obstacle;
sub new {
    my ($class, $canvas, $points) = @_;
    my $self = {
        canvas => $canvas,
        points => $points,
        isPassed => 0,
        idPassed => undef,
    };
    bless $self, $class;
    $self->draw();
    return $self;
}
sub draw {
    my ($self) = @_;
    $self->{id} = $self->{canvas}->create_polygon(@{$self->{points}}, -fill => "#1e8000");
    # $self->{canvas}->create_text(@{$self->{points}}, -text => "A wonderful story", -anchor => "nw", -font => "TkMenuFont", -fill => "red");
}



sub toRect {
    my ($self) = @_;
    my @rect = ($self->{points}->[0], $self->{points}->[1], $self->{points}->[4], $self->{points}->[5]);
    return @rect;
}

sub estPassedIndex {
    my ($self,$id) = @_;
    foreach my $i(@{$self->{idPassed}}) {
        if($i == $id) {
            return 1;
        }
    }
    return 0;
}
sub estFranchit {
    my ($self, $helicopter) = @_;
    my $x = $self->{points}->[2];
    if($x < $helicopter->{x} - ($helicopter->{width} / 2) && !$self->{isPassed}) {
        $self->{isPassed} = 1;
        push(@{$self->{idPassed}}, $helicopter->{id});
        return 1;
    }
    return 0;
}

sub getPoint {
    my ($self, $helicopter) = @_;
    my $hObst = $self->{points}->[3];
    my $rep = 3 * $helicopter->{height};
    if($hObst <= $rep) {
        return 4;
    }
    return 2;
}

sub getAll {
    my ($self, $canvas) = @_;
    my $dbh = Util->getDBH();
    my $query = "SELECT * FROM obstacle";
    my $sth = $dbh->prepare($query);
    $sth->execute();
    my @obstacles;
    while (my $row = $sth->fetchrow_hashref) {
        my $points = [$row->{x1},$row->{y1},$row->{x2},$row->{y2},$row->{x3},$row->{y3},$row->{x4},$row->{y4}];
        push @obstacles, Obstacle->new($canvas, $points);
    }
    $dbh->disconnect;
    return @obstacles;
}
1;