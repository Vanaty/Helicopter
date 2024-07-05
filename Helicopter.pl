use strict;
use warnings;
require "./Util.pl";
require "./Bomb.pl";

package Helicopter;

sub new {
    my ($class, $canvas, $x, $y) = @_;
    my $self = {
        canvas => $canvas,
        image  => Tkx::image_create_photo(-file => "images/helicopter.png", -width => 50, -height => 25),
        width => 50,
        height => 25,
        x      => $x,
        y      => $y,
        dx     => 0,
        dy     => 3,
        score  => 0,
        bombs => undef,
    };
    bless $self, $class;
    $self->draw();
    return $self;
}
sub draw {
    my ($self) = @_;
    # $self->{text} = $self->{canvas}->create_text(80,20,-text=>"Score: $self->{score}",-font =>"{Arial} 20 bold");
    $self->{id} = $self->{canvas}->create_image($self->{x}, $self->{y}, -image => $self->{image});
    $self->{text} = $self->{canvas}->create_text($self->{x}, $self->{y} - $self->{height}, -text=> "$self->{score}", -font=>"{Arial} 12 bold");
}

sub save {
    my ($self) = @_;
    my $dbh = Util->getDBH();
    my $query = "update helicopter set x=?,y=?";
    my $sth = $dbh->prepare($query);
    $sth->execute($self->{x}, $self->{y});
    $sth->finish();
    $dbh->disconnect();
}

sub getFirst {
    my ($self, $canvas) = @_;
    my $dbh = Util->getDBH();
    my $query = "SELECT * FROM helicopter LIMIT 1";
    my $sth = $dbh->prepare($query);
    $sth->execute();
    my $heli;
    while (my $row = $sth->fetchrow_hashref) {
        $heli = Helicopter->new($canvas, $row->{x}, $row->{y});
    }
    $dbh->disconnect;
    return $heli;
}

sub toRect {
    my ($self) = @_;
    my $hw = ($self->{width} / 2);
    my $hh = ($self->{height} / 2);
    my @heli_rect = ($self->{x} - $hw, $self->{y} - $hh, $self->{x} + $hw, $self->{y} + $hh);

    return @heli_rect;
}

sub check_collision {
    my ($self,$obstacles) = @_;
    my @heli = $self->toRect();
    foreach my $obstacle(@$obstacles) {
        my @obst = ($obstacle->{points}->[0], $obstacle->{points}->[1], $obstacle->{points}->[4], $obstacle->{points}->[5]);
        if(Util->check_collision(\@heli, \@obst)) {
            return 1;
        }
    }
    return 0;
}

sub is_inside_heliport {
    my ($self, $heliports) = @_;
    my @heli = $self->toRect();
    foreach my $heliport(@$heliports) {
        my @heli_p = $heliport->toRect();
        if(Util->insideRect(\@heli_p, \@heli)) {
            return 1;
        }
    }
    return 0   
}

sub insideMap {
    my ($self) = @_;
    my $c_width = $self->{canvas}->cget(-width);
    my $c_height = $self->{canvas}->cget(-height);
    my @c_rect = (0, 0, $c_width, $c_height);

    my @heli_rect = $self->toRect();

    return Util->insideRect(\@c_rect, \@heli_rect);
}

sub sePoser {
    my ($self,$heliports) = @_;
    return ($self->is_inside_heliport($heliports) && $self->{dy} >= 0);
}

sub getScore {
    my ($self, $obstacles) = @_;
    foreach my $obstacle(@$obstacles) {
        if($obstacle->estFranchit($self)) {
            $self->{score} += $obstacle->getPoint($self);
        }
    }
    return $self->{score};
}

sub updateScore {
    my($self) = @_;
    $self->{canvas}->itemconfigure($self->{text},-text=>"Score: $self->{score}");
}

sub bombarder() {
    my($self) = @_;
    my $y = $self->{y} + $self->{height}/2;
    push @{$self->{bombs}}, Bomb->new($self->{canvas},$self->{x}, $y, $self);
}

sub move {
    my ($self, $tanks, $obstacles, $heliports, $heli) = @_;
    if(defined $heli) {    
        $self->{dx} = -1 * $heli->{dx};
        $self->{dy} = -1 * $heli->{dy};
    }

    $self->getScore($obstacles);
    $self->updateScore();
    foreach my $bomb (@{$self->{bombs}}) {
        $bomb->move($tanks, $obstacles);
    }

    $self->{x} += $self->{dx};
    if($self->check_collision($obstacles) || !$self->insideMap()) {
        $self->{x} -= $self->{dx};
    }

    $self->{y} += $self->{dy};
    if($self->check_collision($obstacles) || !$self->insideMap()) {
        $self->{y} -= $self->{dy};
    }

    if($self->sePoser($heliports)) {
        $self->{y} -= $self->{dy};
    }
    $self->{canvas}->coords($self->{text}, $self->{x}, $self->{y} - $self->{height});
    $self->{canvas}->coords($self->{id}, $self->{x}, $self->{y});
}
1;