use strict;
use warnings;
use DBI;
package Util;
sub point_insideRect {
    my ($self, $rectangle, $point) = @_;

    my ($x1, $y1, $x2, $y2) = @$rectangle;
    my ($x, $y) = @$point;

    return ($x >= $x1 && $x <= $x2 && $y >= $y1 && $y <= $y2);
}

sub getDBH {
    my ($self) = @_;
    my $dbh = DBI->connect("DBI:Pg:database=helicopter;host=localhost","postgres","itu16")
    or die "Connection lost $DBI::errstr";
    return $dbh;
}

sub check_collision {
    my ($self, $rect1, $rect2) = @_;
    my ($x1, $y1, $x2, $y2) = @$rect1;
    my ($x1_rect2, $y1_rect2, $x2_rect2, $y2_rect2) = @$rect2;
    my $maxX = max($x1_rect2, $x2_rect2);
    my $minX = min($x1_rect2, $x2_rect2);
    my $maxY = max($y1_rect2, $y2_rect2);
    my $minY = min($y1_rect2, $y2_rect2);
    
    if(($x2 >=$minX && $x2 <=$maxX) || ($minX >=$x1 && $minX <=$x2)) {
        if(($y1 >=$minY && $y1 <=$maxY ) || ($y2 >=$minY && $y2 <=$maxY) || ( $minY >= $y1 && $minY <=$y2 ) || ($maxY >=$y1 && $maxY <=$y2)) {
            return 1;
        }
    }
    if(($x1 >=$minX && $x1 <=$maxX) || ($maxX >=$x2 && $maxX <=$x1) ) {
        if(($y1 >=$minY && $y1 <=$maxY ) || ($y2 >=$minY && $y2 <=$maxY) || ( $minY >= $y1 && $minY <=$y2 )|| ($maxY >=$y1 && $maxY <=$y2)){
            return 1;
        }
    }    
    
    return 0;
}

#dans $Rect 2 ve $Rect 1;
sub insideRect {
    my ($self, $rect2, $rect1) = @_;
    my ($x1, $y1, $x2, $y2) = @$rect1;
    my ($x1_rect2, $y1_rect2, $x2_rect2, $y2_rect2) = @$rect2;
    my $_x = ($x1_rect2 <= $x1 && $x1  <= $x2_rect2) && ($x1_rect2 <= $x2 && $x2  <= $x2_rect2) || ($x2_rect2 <= $x1 && $x1  <= $x1_rect2) && ($x2_rect2 <= $x2 && $x2  <= $x1_rect2);
    my $_y = (($y1_rect2 <= $y1 && $y1  <= $y2_rect2) && ($y1_rect2 <= $y2 && $y2  <= $y2_rect2) || ($y2_rect2 <= $y1 && $y1  <= $y1_rect2) && ($y2_rect2 <= $y2 && $y2  <= $y1_rect2));
    return ($_x && $_y);
}

sub max {
    my ($nbr1,$nbr2) = @_;
    if($nbr1>$nbr2){
        return $nbr1;
    }
    return $nbr2;
}
sub min {
    my ($nbr1,$nbr2) = @_;
    if($nbr1<$nbr2){
        return $nbr1;
    }
    return $nbr2;
}

1;
