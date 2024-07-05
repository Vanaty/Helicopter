use strict;
use warnings;
require "./Util.pl";

package Bomb;

sub new {
    my ($class, $canvas, $x, $y, $helicopter) = @_;
    my $self = {
        canvas => $canvas,
        image  => Tkx::image_create_photo(-file => "images/bomb.png", -width => 13, -height => 30),
        supernova  => Tkx::image_create_photo(-file => "images/supernova.png", -width => 50, -height => 50),
        width => 13,
        height => 30,
        x      => $x,
        y      => $y,
        dx     => 0,
        dy     => 10,
        helicopter  => $helicopter,
    };
    bless $self, $class;
    $self->draw();
    return $self;
}

sub draw {
    my ($self) = @_;
    $self->{id} = $self->{canvas}->create_image($self->{x}, $self->{y}, -image => $self->{image});
}

sub toRect {
    my ($self) = @_;
    my $hw = ($self->{width} / 2);
    my $hh = ($self->{height} / 2);
    my @rect = ($self->{x} - $hw, $self->{y} - $hh, $self->{x} + $hw, $self->{y} + $hh);

    return @rect;
}

sub check_collision {
    my ($self,$obstacles) = @_;
    my @t = $self->toRect();
    foreach my $obstacle(@$obstacles) {
        my @obst = $obstacle->toRect();
        if(Util->check_collision(\@t, \@obst)) {
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
    my @rect = $self->toRect();
    return Util->insideRect(\@c_rect, \@rect);
}

sub getIndiceCible {
    my ($self, $tanks) = @_;
    my @indices;
    my @bomb_rect = $self->toRect();
    for(my $i=0; $i < scalar(@$tanks); $i++) {
        my @tank_rect = @$tanks[$i]->toRect();
        if(Util->check_collision(\@bomb_rect, \@tank_rect)) {
            push @indices, $i;
        }
    }
    return @indices;
}

sub explosion {
    my ($self, $tanks) = @_;
    my @bombs = @{$self->{helicopter}->{bombs}};
    @bombs = grep { $_ != $self } @bombs;
    $self->{helicopter}->{bombs} = \@bombs;

    $self->{canvas}->delete($self->{id});
    $self->{idSupernova} = $self->{canvas}->create_image($self->{x}, $self->{y}, -image => $self->{supernova});
    Tkx::after(700, sub {
        $self->{canvas}->delete($self->{idSupernova});
    });

    my @id_cibles = $self->getIndiceCible($tanks);
    foreach my $id (@id_cibles) {
        @$tanks[$id]->explosion();
        $self->{helicopter}->{score} += @$tanks[$id]->{point};
        splice(@$tanks, $id, 1);
    }
}

sub move {
    my ($self, $tanks, $obstacles) = @_;

    $self->{y} += $self->{dy};

    if($self->check_collision($obstacles) || $self->check_collision($tanks) || !$self->insideMap()) {
        $self->explosion($tanks);
    } else {
        $self->{canvas}->coords($self->{id}, $self->{x}, $self->{y});
    }
}
1;