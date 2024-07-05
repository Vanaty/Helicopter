use strict;
use warnings;
require "./Util.pl";

package Tank;

sub new {
    my ($class, $canvas, $x, $y, $point) = @_;
    my $self = {
        canvas => $canvas,
        image  => Tkx::image_create_photo(-file => "images/tank.png", -width => 50, -height => 25),
        supernova  => Tkx::image_create_photo(-file => "images/supernova.png", -width => 50, -height => 50),
        width => 50,
        height => 25,
        x      => $x,
        y      => $y,
        dx     => 3,
        dy     => 0,
        point  => $point,
    };
    bless $self, $class;
    $self->draw();
    return $self;
}
sub draw {
    my ($self) = @_;
    $self->{id} = $self->{canvas}->create_image($self->{x}, $self->{y}, -image => $self->{image});
    $self->{text} = $self->{canvas}->create_text($self->{x}, $self->{y} - $self->{height}, -text=> "$self->{point}", -font=>"{Arial} 12 bold");
}

sub toRect {
    my ($self) = @_;
    my $hw = ($self->{width} / 2);
    my $hh = ($self->{height} / 2);
    my @tank_rect = ($self->{x} - $hw, $self->{y} - $hh, $self->{x} + $hw, $self->{y} + $hh);

    return @tank_rect;
}

sub check_collision {
    my ($self,$obstacles) = @_;
    my @tank = $self->toRect();
    foreach my $obstacle(@$obstacles) {
        my @obst = ($obstacle->{points}->[0], $obstacle->{points}->[1], $obstacle->{points}->[4], $obstacle->{points}->[5]);
        if(Util->check_collision(\@tank, \@obst)) {
            return 1;
        }
    }
    return 0;
}

sub insideMap {
    my ($self) = @_;
    my $c_width = $self->{canvas}->cget(-width);
    my $c_height = $self->{canvas}->cget(-height);
    my @c_rect = (0, 0, $c_width, $c_height);

    my @heli_rect = $self->toRect();

    return Util->insideRect(\@c_rect, \@heli_rect);
}

sub explosion {
    my ($self) = @_;
    $self->{canvas}->delete($self->{id});
    $self->{canvas}->delete($self->{text});
    $self->{idSupernova} = $self->{canvas}->create_image($self->{x}, $self->{y}, -image => $self->{supernova});
    Tkx::after(700, sub {
        $self->{canvas}->delete($self->{idSupernova});
    });
}

sub move {
    my ($self, $obstacles) = @_;

    $self->{x} += $self->{dx};

    if($self->check_collision($obstacles) || !$self->insideMap()) {
        $self->{dx} *= -1;
        $self->{x} += $self->{dx};
    }
    $self->{canvas}->coords($self->{id}, $self->{x}, $self->{y});
    $self->{canvas}->coords($self->{text}, $self->{x}, $self->{y} - $self->{height});
}

sub getAll {
    my ($self, $canvas) = @_;
    my $dbh = Util->getDBH();
    my $query = "SELECT * FROM tank";
    my $sth = $dbh->prepare($query);
    $sth->execute();
    my @tanks;
    while (my $row = $sth->fetchrow_hashref) {
        push @tanks, Tank->new($canvas, $row->{x}, $row->{y}, $row->{point});
    }
    $dbh->disconnect;
    return @tanks;
}
1;