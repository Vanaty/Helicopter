package Helico;
use strict;
use warnings;
use parent 'Composant';
use Tk::JPEG;
use Tk::PNG;
use Tk::Photo;

sub new {
    my($class,$x1,$x2,$y1,$y2) = @_;
    my $self=$class->SUPER::new($x1,$x2,$y1,$y2);
    $self->{spriteImg} = [];
    push @{$self->{spriteImg}}, "F:\\S4\\Projets-Tahina\\perle\\Helicopter\\img\\Helico-0.png";
    push @{$self->{spriteImg}}, "F:\\S4\\Projets-Tahina\\perle\\Helicopter\\img\\Helico-11.png";
    push @{$self->{spriteImg}}, "F:\\S4\\Projets-Tahina\\perle\\Helicopter\\img\\Helico-28.png";
    push @{$self->{spriteImg}}, "F:\\S4\\Projets-Tahina\\perle\\Helicopter\\img\\Helico-47.png";
    $self->{imgActuel} = 0;
    $self->{width} = $x2 - $x1;
    $self->{height} = $y2 - $y1;
    return $self;
}

#Fonction graphique
sub drawImg {
    my ($self,$panel,$canvas) = @_;
    # Charger l'image
    $self->{imgActuel} = $self->{imgActuel} % 4 ;
    my $original_image = $panel->Photo(-format => "png",-file => $self->{spriteImg}[$self->{imgActuel}]); 
    
    #redimensionné
    # my $resized_image = $panel->Photo(-width => $self->{width}, -height => $self->{height});
    # # Copier les données de l'image originale dans la nouvelle image redimensionnée
    # for my $x (0 .. $self->{width} - 1) {
    #     for my $y (0 .. $self->{height} - 1) {
    #         my @color = $original_image->get($x * $original_image->width / $self->{width}, $y * $original_image->height / $self->{height});
    #         my $color = sprintf("#%02x%02x%02x", @color); # Convertir la couleur RGB en format hexadécimal
    #         $resized_image->put($color, -to => $x, $y);
    #     }
    # }
    #Afficher
    my $image_id = $canvas->createImage($self->{x1}, $self->{y1}, -image => $original_image, -anchor => 'nw');
    
}

#Fonction du jeu

sub nextMoveTouch {
    my ($self,$x1,$x2,$y1,$y2,$obstacle) = @_;
    my $maxX = max($obstacle->{x1},$obstacle->{x2});
    my $minX = min($obstacle->{x1},$obstacle->{x2});
    my $maxY = max($obstacle->{y1},$obstacle->{y2});
    my $minY = min($obstacle->{y1},$obstacle->{y2});
    
     
    if(($x2 >=$minX && $x2 <=$maxX) || ($minX >=$x1 && $minX <=$x2) ){
        if(($y1 >=$minY && $y1 <=$maxY )|| ($y2 >=$minY && $y2 <=$maxY) || ( $minY >= $y1 && $minY <=$y2 )|| ($maxY >=$y1 && $maxY <=$y2) ){

            return 1;
        }
    }
    if(($x1 >=$minX && $x1 <=$maxX) || ($maxX >=$x2 && $maxX <=$x1) ){
        if(($y1 >=$minY && $y1 <=$maxY )|| ($y2 >=$minY && $y2 <=$maxY) || ( $minY >= $y1 && $minY <=$y2 )|| ($maxY >=$y1 && $maxY <=$y2)){
            return 1;
        }
    }    
    
    return 0;
}
sub inArrive {
    my ($self,$arrive) = @_;
    my $maxX = max($arrive->{x1},$arrive->{x2});
    my $minX = min($arrive->{x1},$arrive->{x2});
    my $maxY = max($arrive->{y1},$arrive->{y2});
    my $minY = min($arrive->{y1},$arrive->{y2});
         
    
    my $gagnant = 0; #Raha feno 2
    if($self->{x1} > $minX && $self->{x1} < $maxX && ($self->{y2} - $maxY) >=  0  && ($self->{y2} - $maxY) <= 1 ){
        $gagnant++;
    }

    if($self->{x2} > $minX && $self->{x2} < $maxX && ($self->{y2} - $maxY) >=  0  && ($self->{y2} - $maxY) <= 1 ){
        $gagnant++;
    }

    if($gagnant==2){
        $self->{imgActuel} = 0;
        return 0;
    }

    return 1; # Mbola

}

#Utilitaire
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

#setters and getters
sub setImg {
    my($self,$img)=@_;
    $self->{img} = $img;
}
sub getImg {
    my $self = shift;
    return $self->{img}
}
1;

